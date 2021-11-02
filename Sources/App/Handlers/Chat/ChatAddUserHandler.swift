import PromiseKit
import Foundation

struct ChatAddUserHandler: IRequestHandler {
    var name: String {
        "chat/add_user"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<EmptyRaw> {
        parameters.getUser.then { info in
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
                request: DBGetContainsUserInChat(
                    userId: parameters.input.userId,
                    chatId: parameters.input.chatId
                )
            )
        }.map { result -> Void in
            if result.first?.count ?? 0 > 0 {
                throw Errors.userAlreadyInChat.description(
                    "Пользователь уже состоит в данном чате"
                )
            }
            return Void()
        }.then { _ in
            firstly {
                dataBase.run(request: DBGetChatRequest(chatId: parameters.input.chatId))
            }.only.map { result -> ChatsOutput.Chat in
                if result.content1.is_personal != 0 {
                    throw Errors.accessError.description(
                        "Добавление в персональные чаты недоступно"
                    )
                }
                return .init(result, authorisationInfo: parameters.authorisationInfo)
            }
        }.then { chat in
            dataBase.run(
                request: DBAddUserInChatRequest(
                    userId: parameters.input.userId,
                    chatId: parameters.input.chatId
                )
            ).get { _ in
                parameters.updateCenter.update(action: .addInNewChat(chat, userId: parameters.input.userId))
            }
        }.map { _ in
            EmptyRaw()
        }
    }
}

extension ChatAddUserHandler {
    struct Input: Codable {
        let chatId: IdentifierType
        let userId: IdentifierType
    }
}
