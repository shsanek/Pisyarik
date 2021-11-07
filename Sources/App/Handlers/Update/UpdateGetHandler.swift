import Foundation

struct UpdateGetHandler: IRequestHandler {

    var name: String {
        "update/add_listener"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> FuturePromise<Output> {
        parameters.getUser.then { info -> FuturePromise<Void> in
            guard let ws = parameters.ws else {
                throw Errors.internalError.description("По этому методу можно стучаться только в ws")
            }
            return parameters.updateCenter.addListener(token: info.token, ws: ws)
        }.map { _ in
            Output()
        }
    }
}

extension UpdateGetHandler {
    struct Output: Encodable {
    }
}
