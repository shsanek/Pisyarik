import Vapor

struct NewPersonalChatAction {
    let output: ChatMakePersonalHandler.Output
    let userId: IdentifierType
}

extension NewPersonalChatAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput(type: .newPersonalChat, content: output)
        let container = NotificationOutputContainer(notification)
        let pushInfo = PushInfo(title: "\(output.user.name)", text: "Начал диалог")
        let updater = InformationUpdater(userId: userId, container: container, pushInfo: pushInfo)
        return .value([updater])
    }
}
