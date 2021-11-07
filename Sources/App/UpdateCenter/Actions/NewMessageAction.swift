import Vapor

struct NewMessageAction {
    let message: MessageOutput
}

extension NewMessageAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput(
            type: .newMessage,
            content: message
        )
        let container = NotificationOutputContainer(notification)
        return dataBase.run(request: DBGetUserRequest(chatId: message.chatId)).map { [message] users in
            users.filter { $0.user_id != message.user.userId }.map { user in
                InformationUpdater(
                    userId: user.user_id,
                    container: container,
                    pushInfo: .init(
                        title: message.user.name,
                        text: String(message.content.prefix(100))
                    )
                )
            }
        }
    }
}
