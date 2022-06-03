import Vapor

final class InformationUpdater {
    let tokens: [Token]
    let output: NotificationOutput
    let pushInfo: PushInfo?

    init(
        tokens: [Token],
        output: NotificationOutput,
        pushInfo: PushInfo?
    ) {
        self.tokens = tokens
        self.output = output
        self.pushInfo = pushInfo
    }
}

extension InformationUpdater {
    struct Token {
        let userId: IdentifierType
        let token: String
        let apns: String?
    }
}

struct PushInfo {
    let title: String
    let subtitle: String?
    let text: String
    let chatId: IdentifierType
}

extension InformationUpdater {
    func send(token: String?, dataBase: IDataBase, app: Application) {
        guard let pushInfo = pushInfo, let token = token else {
            return
        }
        app.apns.send(
            Push(
                aps: .init(
                    alert: .init(
                        title: pushInfo.title,
                        subtitle: pushInfo.subtitle,
                        body: String(pushInfo.text.prefix(500))
                    ),
                    sound: .normal("default"),
                    threadID: "\(pushInfo.chatId)"
                ),
                chatId: pushInfo.chatId
            ),
            to: token
        ).whenComplete { result in
        }
    }
}
