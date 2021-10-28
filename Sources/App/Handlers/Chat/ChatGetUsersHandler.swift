import PromiseKit
import Foundation

struct ChatGetUsersHandler: IRequestHandler {
    var name: String {
        "chat/get_users"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<UsersOutput> {
        parameters.getUser.then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.map({ result -> Void in
            if result.first?.count ?? 0 == 0 {
                throw UserError.accessError
            }
            return Void()
        }).then { _ in
            dataBase.run(request: DBGetUserRequest(chatId: parameters.input.chatId))
        }.map { result in
            UsersOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension ChatGetUsersHandler {
    struct Input: Codable {
        let chatId: IdentifierType
    }
}

