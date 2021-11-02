import PromiseKit
import Foundation

struct ChatGetAllMyHandler: IRequestHandler {
    var name: String {
        "chat/get_all_my"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) -> Promise<ChatsOutput> {
        parameters.getUser.then { info in
            dataBase.run(request: DBGetChatRequest(userId: info.identifier))
        }.map { result in
            ChatsOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}
