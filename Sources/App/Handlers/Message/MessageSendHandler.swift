import Foundation

struct MessageSendHandler: IRequestHandler {
    var name: String {
        "message/send"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<MessageOutput> {
        let time = UInt(Date.timeIntervalSinceReferenceDate)
        return parameters.getUser.then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.handle { result in
            if result.first?.count ?? 0 == 0 {
                throw Errors.accessError.description(
                    "Пользователя нет в этом чате"
                )
            }
        }.next {
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
            ).only().get { identifier in
                parameters.updateCenter.update(
                    action: NewMessageAction(
                        autor: info,
                        message: .init(
                            user: .init(info.user, authorisationInfo: nil),
                            date: time,
                            content: parameters.input.content,
                            type: parameters.input.type,
                            messageId: identifier.identifier,
                            chatId: parameters.input.chatId
                        ),
                        chatId: parameters.input.chatId
                    )
                )
            }
        }.then { result in
            dataBase.run(request: DBGetMessage(messageId: result.identifier))
        }.only().map { raw in
            MessageOutput(
                raw,
                authorisationInfo: parameters.authorisationInfo
            )
        }
    }
}

extension MessageSendHandler {
    struct Input: Codable {
        let chatId: IdentifierType
        let type: String
        let content: String
    }
}
