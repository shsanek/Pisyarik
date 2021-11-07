import Vapor

struct NewPersonalChatAction {
    let chat: ChatOutput
    let userId: IdentifierType
}

extension NewPersonalChatAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput(type: .newPersonalChat, content: chat)
        let container = NotificationOutputContainer(notification)
        let pushInfo = PushInfo(title: "\(chat.name)", text: "Начал диалог")
        let updater = InformationUpdater(userId: userId, container: container, pushInfo: pushInfo)
        return .value([updater])
    }
}
