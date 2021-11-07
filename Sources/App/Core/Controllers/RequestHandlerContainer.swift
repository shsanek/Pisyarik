import Vapor

protocol IRequestHandlerContainer {
    var name: String { get }

    func handle(
        _ data: ByteBuffer?,
        dataBase: IDataBase,
        updateCenter: UpdateCenter,
        ws: WebSocket?
    ) -> FuturePromise<String>
}

struct RequestHandlerContainer<Handler: IRequestHandler> {
    let name: String

    private let handler: Handler

    init(handler: Handler) {
        self.name = handler.name
        self.handler = handler
    }
}

extension RequestHandlerContainer: IRequestHandlerContainer {
    func handle(
        _ data: ByteBuffer?,
        dataBase: IDataBase,
        updateCenter: UpdateCenter,
        ws: WebSocket?
    ) -> FuturePromise<String> {
        return firstly { () -> FuturePromise<InputRequestRaw<Handler.Input>> in
            guard let bf = data else {
                throw Errors.internalError.description("Так забыл тело к запросу пришить")
            }
            let raw = try bf.json(type: InputRequestRaw<Handler.Input>.self)
//            guard abs(Int64(raw.time) - Int64(Date.serverTime)) < 1000 * 60 else {
//                throw NSError(domain: "Time to disperse by more than 10 minutes", code: 1, userInfo: nil)
//            }
            return .value(raw)
        }.then { raw -> FuturePromise<String> in
            return try self.checkToken(
                raw,
                ws: ws,
                dataBase: dataBase,
                updateCenter: updateCenter
            ).then { parameters in
                try handler.handle(parameters, dataBase: dataBase)
            }.mapToResponse(requestId: raw.reuestId, method: handler.name)
        }
    }

    private func checkToken<Input: Decodable>(
        _ raw: InputRequestRaw<Input>,
        ws: WebSocket?,
        dataBase: IDataBase,
        updateCenter: UpdateCenter
    ) throws -> FuturePromise<RequestParameters<Input>> {
        guard let authorisation = raw.authorisation else {
            return .value(
                RequestParameters(
                    authorisationInfo: nil,
                    updateCenter: updateCenter,
                    input: raw.content,
                    time: raw.time,
                    ws: ws
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
                time: raw.time,
                ws: ws
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
