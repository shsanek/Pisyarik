import Vapor

struct NewMessageAction {
    let autor: AuthorisationInfo?
    let message: MessageOutput
}

extension NewMessageAction: IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]> {
        let notification = NotificationOutput.newMessage(message: message)
        let pushInfo = PushInfo(
            title: message.user.name,
            text: String(message.content.prefix(500))
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
