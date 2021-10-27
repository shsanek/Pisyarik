import PromiseKit
import Foundation

struct ChatAddUserHandler: IRequestHandler {
    var name: String {
        return "chat/add_user"
    }
    
    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<EmptyRaw> {
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
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: parameters.input.userId,
                    chatId: parameters.input.chatId
                )
            )
        }.map({ result -> Void in
            if result.first?.count ?? 0 > 0 {
                throw UserError.alreadyInChat
            }
            return Void()
        }).then { _ in
            dataBase.run(
                request: DBAddUserInChatRequest(
                    userId: parameters.input.userId,
                    chatId: parameters.input.chatId
                )
            )
        }.map({ _ in
            EmptyRaw()
        })
    }
}

extension ChatAddUserHandler {
    struct Input: Codable {
        let chatId: IdentifierType
        let userId: IdentifierType
    }
}

extension UserError {
    static var alreadyInChat: UserError {
        UserError(name: "Already in chat", description: "User already added in chat", info: nil)
    }
}
