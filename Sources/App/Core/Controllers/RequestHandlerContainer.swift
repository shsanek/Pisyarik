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
                throw NSError(domain: "Incorrect body", code: 1, userInfo: nil)
            }
            guard let raw = try bytes.readJSONDecodable(InputRequestRaw<Handler.Input>.self, length: bytes.readableBytes) else {
                throw NSError(domain: "Incorrect json", code: 1, userInfo: nil)
            }
//            guard abs(Int64(raw.time) - Int64(Date.serverTime)) < 1000 * 60 else {
//                throw NSError(domain: "Time to disperse by more than 10 minutes", code: 1, userInfo: nil)
//            }
            return raw
        }.then { (raw) -> Promise<RequestParameters<Handler.Input>> in
            guard let token = raw.authorisation?.token else {
                return .value(RequestParameters(authorisationInfo: nil, updateCenter: updateCenter, input: raw.parameters, time: raw.time))
            }
            guard let secret = raw.authorisation?.secretKey else {
                return .init(error: UserError.incorrectToken)
            }
            let result = Promise<RequestParameters<Handler.Input>>.pending()
            dataBase.run(request: DBGetUserRequest(token: token)).only.handler { user in
                guard String(user.content.secret_key?.hash(with: raw.time)?.prefix(64) ?? "") == String(secret.prefix(64)) else {
                    throw UserError.incorrectToken
                }
            }.map { user in
                AuthorisationInfo(
                    identifier: user.identifier,
                    name: user.content.name
                )
            }.done { value in
                result.resolver.fulfill(RequestParameters(authorisationInfo: value, updateCenter: updateCenter, input: raw.parameters, time: raw.time))
            }.catch { error in
                result.resolver.reject(UserError.incorrectToken)
            }
            return result.promise
        }.then { parameters  in
            handler.handle(parameters, dataBase: dataBase)
        }.done { result in
            promise.ok(result)
        }.catch { error in
            promise.errors([error])
        }
        return promise.futureResult
    }
}
