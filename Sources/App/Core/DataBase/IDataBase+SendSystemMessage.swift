import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension IDataBase {
    func sendSystemMessage(
        chatId: IdentifierType,
        message: String,
        updateCenter: UpdateCenter? = nil
    ) -> FuturePromise<MessageOutput> {
        let date = UInt(Date.timeIntervalSinceReferenceDate)
        return self.run(
            request: DBAddMessageRequest(
                message: DBMessageRaw(
                    message_author_id: DBUserRaw.systemUserId,
                    message_chat_id: chatId,
                    message_date: date,
                    message_body: message,
                    message_type: "SYSTEM_TEXT",
                    message_id: 0
                )
            )
        ).only().map {
            $0.identifier
        }.then { identifier in
            run(request: DBGetLightChatRequest(chatId: chatId)).only().map { chat in
                MessageOutput(
                    user: .init(
                        name: chat.chat_name,
                        userId: DBUserRaw.systemUserId,
                        isSelf: false,
                        hex: nil,
                        emoji: nil,
                        firstName: nil,
                        lastName: nil
                    ),
                    date: date,
                    content: message,
                    type: "SYSTEM_TEXT",
                    messageId: identifier,
                    chatId: chatId
                )
            }
        }.get { output in
            updateCenter?.update(
                action: NewMessageAction(autor: nil, message: output, chatId: nil))
        }
    }
}
