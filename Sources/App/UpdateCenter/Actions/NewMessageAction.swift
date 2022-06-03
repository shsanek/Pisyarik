import Vapor

struct NewMessageAction {
    let autor: AuthorisationInfo?
    let message: MessageOutput
    let chatId: IdentifierType?
}

extension NewMessageAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        if let chatId = chatId {
            return dataBase.run(request: DBGetLightChatRequest(chatId: chatId)).only().then { chat in
                self.generateUpdaters(dataBase, chat: chat)
            }
        } else {
            return self.generateUpdaters(dataBase, chat: nil)
        }
    }

    private func generateUpdaters(
        _ dataBase: IDataBase,
        chat: DBChatRaw?
    ) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput.newMessage(message: message)
        let chatName = chat?.chat_type == ChatType.personal.rawValue ? nil : chat?.chat_name
        let pushInfo = PushInfo(
            title: chatName ?? message.user.name,
            subtitle: chatName != nil ? message.user.name : nil,
            text: String(message.content.prefix(500)),
            chatId: message.chatId
        )
        return dataBase.getAllUpdateTokenForChat(message.chatId, autor: autor).map { tokens in
            tokens.map { token -> InformationUpdater in
                if token.userId == autor?.identifier {
                    let notification = NotificationOutput.newMessage(message: message.convertToSelf())
                    return InformationUpdater(tokens: [token], output: notification, pushInfo: nil)
                }
                return InformationUpdater(tokens: [token], output: notification, pushInfo: pushInfo)
            }
        }
    }

}
