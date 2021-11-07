import Vapor
import APNS

final class UpdateCenter {
    private let dataBase: IDataBase
    private let lock = Lock()
    private var listeners: [String: Listener] = [:]
    private let app: Application

    init(dataBase: IDataBase, app: Application) {
        self.dataBase = dataBase
        self.app = app
    }

    func addListener(
        token: String,
        ws: WebSocket
    ) -> FuturePromise<Void> {
        self.updateWS(token: token, ws: ws)
        return .value(Void())
    }

    func update(action: IUpdateAction) {
        let updaters = action.generateUpdaters(dataBase)
        try? updaters.make(app.eventLoopGroup.next()).whenComplete { [weak self] result in
            switch result {
            case .success(let updaters):
                self?.update(updaters)
            case .failure:
                break
            }
        }
    }

    private func update(_ updaters: [InformationUpdater]) {
        for updater in updaters {
            try? dataBase.run(request: DBGetUserTokenRequest(userId: updater.userId)).handle { result in
                self.lock.lockReading()
                defer {
                    self.lock.unlock()
                }
                for token in result {
                    if let listener = self.listeners[token.identifier] {
                        listener.append(updater)
                    } else {
                        updater.send(token: token.identifier, dataBase: self.dataBase, app: self.app)
                    }
                }
            }.make(app.eventLoopGroup.next()).whenComplete { _ in }
        }
    }

    private func updateWS(token: String, ws: WebSocket) {
        self.lock.lockWriting()
        defer {
            self.lock.unlock()
        }
        if let listener = listeners[token] {
            listener.updateConnect(ws)
            return
        }
        listeners[token] = Listener(ws: ws, app: app, dataBase: dataBase, token: token) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.lock.lockWriting()
            defer {
                self.lock.unlock()
            }
            self.listeners[token] = nil
        }
    }
}
