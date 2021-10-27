import PromiseKit
import Vapor

struct RequestHandlerContainer<Handler: IRequestHandler> {
    private let handler: Handler
    
    init(handler: Handler) {
        self.handler = handler
    }
}

extension RequestHandlerContainer {
    func handle(_ request: Request, dataBase: IDataBase) -> EventLoopFuture<String> {
        let promise: EventLoopPromise<String> = request.eventLoop.makePromise()
        Promise.value(request).map { request -> InputRequestRaw<Handler.Input> in
            guard var bytes = request.body.data else {
                throw NSError(domain: "Incorrect body", code: 1, userInfo: nil)
            }
            guard let raw = try bytes.readJSONDecodable(InputRequestRaw<Handler.Input>.self, length: bytes.readableBytes) else {
                throw NSError(domain: "Incorrect json", code: 1, userInfo: nil)
            }
            return raw
            
        }.then { (raw) -> Promise<RequestParameters<Handler.Input>> in
            guard let token = raw.token else {
                return .value(RequestParameters(authorisationInfo: nil, input: raw.parameters))
            }
            let result = Promise<RequestParameters<Handler.Input>>.pending()
            dataBase.run(request: DBGetUserRequest(token: token)).only.map { user in
                AuthorisationInfo(
                    identifier: user.identifier,
                    name: user.content.name
                )
            }.done { value in
                result.resolver.fulfill(RequestParameters(authorisationInfo: value, input: raw.parameters))
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

