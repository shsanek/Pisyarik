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
    let text: String
}

extension InformationUpdater {
    func send(token: String?, dataBase: IDataBase, app: Application) {
        guard let pushInfo = pushInfo, let token = token else {
            return
        }
        app.apns.send(
            .init(
                alert: .init(title: pushInfo.title, body: String(pushInfo.text.prefix(500))),
                sound: .normal("default")
            ),
            to: token
        ).whenComplete { result in
        }
    }
}
