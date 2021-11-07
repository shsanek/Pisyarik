import Vapor

final class InformationUpdater {
    let userId: IdentifierType
    let container: NotificationOutputContainer
    let pushInfo: PushInfo?

    init(
        userId: IdentifierType,
        container: NotificationOutputContainer,
        pushInfo: PushInfo?
    ) {
        self.userId = userId
        self.container = container
        self.pushInfo = pushInfo
    }
}

struct PushInfo {
    let title: String
    let text: String
}

extension InformationUpdater {
    func send(token: String, dataBase: IDataBase, app: Application) {
        guard let pushInfo = pushInfo else {
            return
        }
        try? firstly {
            dataBase.run(request: DBApnsTokenRequest(token: token))
        }.handle { tokens in
            for token in tokens {
                if let id = token.identifier {
                    app.apns.send(
                        .init(title: pushInfo.title, subtitle: pushInfo.text),
                        to: id
                    ).whenComplete { result in
                        print(result)
                        }
                }
            }
        }.make(app.eventLoopGroup.next()).whenComplete { _ in }
    }
}
