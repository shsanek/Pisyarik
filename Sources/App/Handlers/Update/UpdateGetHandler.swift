import PromiseKit
import Foundation

struct UpdateGetHandler: IRequestHandler {

    var name: String {
        "update/get"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) -> Promise<Output> {
        parameters.getUser.then { info in
            parameters.updateCenter.addListener(id: info.identifier)
        }.map { notifications in
            Output(notifications: notifications)
        }
    }
}

extension UpdateGetHandler {
    struct Output: Encodable {
        let notifications: [NotificationOutputContainer]
    }
}
