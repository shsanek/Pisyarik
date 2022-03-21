struct AddInNewChatAction {
    let autor: AuthorisationInfo?
    let chat: ChatOutput
    let userId: IdentifierType
}

extension AddInNewChatAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput.newChat(chat: chat)
        let pushInfo = PushInfo(title: "\(chat.name)", text: "Добро пожаловать в чат")
        return dataBase.getAllUpdateTokenForChat(chat.chatId, autor: autor).map { tokens in
            return [InformationUpdater(tokens: tokens, output: notification, pushInfo: pushInfo)]
        }
    }
}
