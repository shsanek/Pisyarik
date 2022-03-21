import Foundation
import Vapor

final class Listener {
    private let killMeHandler: (Listener) -> Void
    @Locked private var updaters: [InformationUpdater] = []
    @Locked private var ws: WebSocket
    private let app: Application
    private let token: String
    private let dataBase: IDataBase

    init(
        ws: WebSocket,
        app: Application,
        dataBase: IDataBase,
        token: String,
        killMeHandler: @escaping (Listener) -> Void
    ) {
        self.killMeHandler = killMeHandler
        self.ws = ws
        self.dataBase = dataBase
        self.app = app
        self.token = token
    }

    func append(_ updater: InformationUpdater) {
        self.updaters.append(updater)
        self.update()
    }

    func updateConnect(_ ws: WebSocket) {
        self.ws = ws
        ws.onClose.whenComplete { [weak self] _ in
            self?.closeConnect(ws)
            print("close connect")
        }
        self.update()
    }

    private func closeConnect(_ ws: WebSocket) {
        guard self.ws === ws else {
            self.update()
            return
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 30) { [weak self] in
            if self?.ws === ws {
                self?.kill()
            }
        }
    }

    private func kill() {
        killMeHandler(self)
    }

    private func update() {
        let updaters = self.updaters
        self.updaters.removeFirst(updaters.count)
        let content = UpdateOutput(notifications: updaters.map { $0.output })
        let output = OutputRequestRaw.ok(content, requestId: nil, method: "update")
        let data = try? JSONEncoder().encode(output)
        guard let data = data else {
            return
        }
        let promise: EventLoopPromise<Void> = app.eventLoopGroup.next().makePromise()
        ws.send(raw: data, opcode: .text, promise: promise)
        promise.futureResult.whenComplete { [weak self, ws] result in
            switch result {
            case .failure:
                self?.updaters.insert(contentsOf: updaters, at: 0)
                self?.closeConnect(ws)
            case .success:
                break
            }
        }
    }
}

private struct UpdateOutput: Encodable {
    let notifications: [NotificationOutput]
}
