import PromiseKit
import Vapor

struct RequestHandlerContainer<Handler: IRequestHandler> {
    private let handler: Handler

    init(handler: Handler) {
        self.handler = handler
    }
}

extension RequestHandlerContainer {
    func handle(_ request: Request, dataBase: IDataBase, updateCenter: UpdateCenter) -> EventLoopFuture<String> {
        let promise: EventLoopPromise<String> = request.eventLoop.makePromise()
        Promise.value(request).map { request -> InputRequestRaw<Handler.Input> in
            guard var bytes = request.body.data else {
                throw Errors.internalError.description("Так забыл тело к запросу пришить")
            }
            let optionRaw = try Errors.internalError.handle("Чет с json проверь параметры") {
                try bytes.readJSONDecodable(
                    InputRequestRaw<Handler.Input>.self,
                    length: bytes.readableBytes
                )
            }
            guard let raw = optionRaw else {
                throw Errors.internalError.description("JSON nil оч странное поведение пни сервериста")
            }
//            guard abs(Int64(raw.time) - Int64(Date.serverTime)) < 1000 * 60 else {
//                throw NSError(domain: "Time to disperse by more than 10 minutes", code: 1, userInfo: nil)
//            }
            return raw
        }.then { raw -> Promise<RequestParameters<Handler.Input>> in
            try self.checkToken(raw, dataBase: dataBase, updateCenter: updateCenter)
        }.then { parameters  in
            try handler.handle(parameters, dataBase: dataBase)
        }.done { result in
            promise.ok(result)
        }.catch { error in
            promise.errors([error])
        }
        return promise.futureResult
    }

    private func checkToken<Input: Decodable>(
        _ raw: InputRequestRaw<Input>,
        dataBase: IDataBase,
        updateCenter: UpdateCenter
    ) throws -> Promise<RequestParameters<Input>> {
        guard let authorisation = raw.authorisation else {
            return .value(
                RequestParameters(
                    authorisationInfo: nil,
                    updateCenter: updateCenter,
                    input: raw.content,
                    time: raw.time
                )
            )
        }
        let token = authorisation.token
        let secret = authorisation.secretKey
        let result = Promise<RequestParameters<Input>>.pending()
        dataBase.run(request: DBGetTokenUserRequest(token: token)).only.handler { container in
            let secret_key = String(container.content2.token_secret_key.hash(with: raw.time)?.prefix(64) ?? "")
            guard
                secret_key == String(secret.prefix(64))
            else {
                throw Errors.incorrectToken.description("Однако неверный ключик вышел")
            }
        }.map { user in
            AuthorisationInfo(
                identifier: user.content1.user_id,
                token: token,
                user: user.content1
            )
        }.done { value in
            result.resolver.fulfill(
                RequestParameters(
                    authorisationInfo: value,
                    updateCenter: updateCenter,
                    input: raw.content,
                    time: raw.time
                )
            )
        }.catch { error in
            var error = UserError(error)
            error.code = Errors.incorrectToken.rawValue
            result.resolver.reject(error)
        }
        return result.promise
    }
}
