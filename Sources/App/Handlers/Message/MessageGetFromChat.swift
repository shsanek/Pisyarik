import PromiseKit
import Foundation

struct MessageGetFromChat: IRequestHandler {
    var name: String {
        "message/get_from_chat"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<MessagesOutput> {
        Promise.value(parameters).map { _ -> Void in
            if parameters.input.limit > 100 {
                throw Errors.internalError.description(
                    "Превышен лимит в 100"
                )
            }
            return Void()
        }
        .then { _ in parameters.getUser }
        .then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.map { result -> Void in
            if result.first?.count ?? 0 == 0 {
                throw Errors.accessError.description(
                    "Пользователя нет в этом чате"
                )
            }
            return Void()
        }.then { _ in
            dataBase.run(
                request: DBGetMessage(
                    limit: max(100, parameters.input.limit),
                    chatId: parameters.input.chatId,
                    lastMessage: parameters.input.lastMessageId,
                    reverse: parameters.input.reverse ?? false
                )
            )
        }.map {
            MessagesOutput($0, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension MessageGetFromChat {
    struct Input: Codable {
        let chatId: IdentifierType
        let limit: Int
        let lastMessageId: IdentifierType?
        let reverse: Bool?
    }
}
