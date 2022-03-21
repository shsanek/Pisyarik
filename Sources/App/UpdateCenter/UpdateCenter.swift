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
        self.lock.lockReading()
        let listeners = listeners
        self.lock.unlock()
        for updater in updaters {
            for token in updater.tokens {
                if let listener = listeners[token.token] {
                    listener.append(updater)
                }
                updater.send(token: token.apns, dataBase: self.dataBase, app: self.app)
            }
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
