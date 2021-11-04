import Vapor

struct RequestHandlerContainer<Handler: IRequestHandler> {
    private let handler: Handler

    init(handler: Handler) {
        self.handler = handler
    }
}

extension RequestHandlerContainer {
    func handle(_ request: Request, dataBase: IDataBase, updateCenter: UpdateCenter) -> EventLoopFuture<String> {
        let result = try? FuturePromise.value(request).map { request -> InputRequestRaw<Handler.Input> in
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
        }.then { raw in
            try self.checkToken(raw, dataBase: dataBase, updateCenter: updateCenter)
        }.then { parameters  in
            try handler.handle(parameters, dataBase: dataBase)
        }.mapToResponse().make(request.eventLoop)
        return result ?? .defaultError(request.eventLoop)
    }

    private func checkToken<Input: Decodable>(
        _ raw: InputRequestRaw<Input>,
        dataBase: IDataBase,
        updateCenter: UpdateCenter
    ) throws -> FuturePromise<RequestParameters<Input>> {
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
        return dataBase.run(request: DBGetTokenUserRequest(token: token)).only().handle { container in
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
        }.map { value in
            RequestParameters(
                authorisationInfo: value,
                updateCenter: updateCenter,
                input: raw.content,
                time: raw.time
            )
        }.mapError { error in
            var error = UserError(error)
            error.code = Errors.incorrectToken.rawValue
            return error
        }
    }
}

extension EventLoopFuture where Value == String {
    static func defaultError(_ loop: EventLoop) -> EventLoopFuture<String> {
        let promise: EventLoopPromise<String> = loop.makePromise()
        promise.succeed(UserError.defaultError)
        return promise.futureResult
    }
}
