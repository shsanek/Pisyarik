import PromiseKit
import Foundation

struct MessageSendHandler: IRequestHandler {
    var name: String {
        "message/send"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        let time = UInt(Date.timeIntervalSinceReferenceDate)
        return parameters.getUser.then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.handler { result in
            if result.first?.count ?? 0 == 0 {
                throw Errors.accessError.description(
                    "Пользователя нет в этом чате"
                )
            }
        }.then { _ in
            parameters.getUser
        }.then { info in
            dataBase.run(
                request: DBAddMessageRequest(
                    message: DBMessageRaw(
                        message_author_id: info.identifier,
                        message_chat_id: parameters.input.chatId,
                        message_date: time,
                        message_body: parameters.input.content,
                        message_type: parameters.input.type,
                        message_id: 0
                    )
                )
            ).only.get { identifier in
                parameters.updateCenter.update(
                    action: .newMessage(
                        .init(
                            user: .init(name: info.name, userId: info.identifier, isSelf: false),
                            date: time,
                            content: parameters.input.content,
                            type: parameters.input.type,
                            messageId: identifier.identifier,
                            chatId: parameters.input.chatId
                        )
                    )
                )
            }
        }.map { result in
            Output(messageId: result.identifier)
        }
    }
}

extension MessageSendHandler {
    struct Input: Codable {
        let chatId: IdentifierType
        let type: String
        let content: String
    }
    struct Output: Codable {
        let messageId: IdentifierType
    }
}
