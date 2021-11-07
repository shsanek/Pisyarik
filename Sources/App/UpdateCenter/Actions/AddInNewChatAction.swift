struct AddInNewChatAction {
    let chat: ChatOutput
    let userId: IdentifierType
}

extension AddInNewChatAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput(type: .addedInNewChat, content: chat)
        let container = NotificationOutputContainer(notification)
        let pushInfo = PushInfo(title: "\(chat.name)", text: "Добро пожаловать в чат")
        let updater = InformationUpdater(userId: userId, container: container, pushInfo: pushInfo)
        return .value([updater])
    }
}
