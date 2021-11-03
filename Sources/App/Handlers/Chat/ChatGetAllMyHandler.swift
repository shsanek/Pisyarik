import PromiseKit
import Foundation

struct ChatGetAllMyHandler: IRequestHandler {
    var name: String {
        "chat/get_all_my"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> Promise<ChatListOutput> {
        parameters.getUser.then { info in
            dataBase.run(request: DBGetChatRequest(userId: info.identifier))
        }.map { result in
            ChatListOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}
