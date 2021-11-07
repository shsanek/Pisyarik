import Vapor

final class RootRouter {
    private let dataBase: IDataBase
    private let app: Application
    private lazy var updateCenter = UpdateCenter(dataBase: dataBase, app: app)
    private var containers: [IRequestHandlerContainer] = []

    init(dataBase: IDataBase, app: Application) {
        self.dataBase = dataBase
        self.app = app
    }

    func registration<Handler: IRequestHandler>(handler: Handler) {
        let container = RequestHandlerContainer(handler: handler)
        containers.append(container)
        app.get(handler.name.pathComponents) { request -> EventLoopFuture<String> in
            let result = try? container.handle(
                request.body.data,
                dataBase: self.dataBase,
                updateCenter: self.updateCenter,
                ws: nil
            ).make(request.eventLoop)
            return result ?? .defaultError(request.eventLoop)
        }
        app.post(handler.name.pathComponents) { request -> EventLoopFuture<String> in
            let result = try? container.handle(
                request.body.data,
                dataBase: self.dataBase,
                updateCenter: self.updateCenter,
                ws: nil
            ).make(request.eventLoop)
            return result ?? .defaultError(request.eventLoop)
        }
    }

    func activeWebSocket() {
        app.webSocket { [containers] request, ws in
            ws.onBinary { ws, bf in
                try? firstly {
                    return try .value(bf.json(type: InputRequestRawMetaInfo.self))
                }.then { info -> FuturePromise<String> in
                    guard let container = containers.first(where: { $0.name == info.method }) else {
                        return FuturePromise<String>.error(
                            Errors.methodNotFound.description("Для данного метода нет обработчиков")
                        ).mapToResponse(requestId: info.reuestId, method: info.method)
                    }
                    return container.handle(
                        bf,
                        dataBase: self.dataBase,
                        updateCenter: self.updateCenter,
                        ws: ws
                    )
                }.make(request.eventLoop).whenComplete { result in
                    switch result {
                    case .success(let result):
                        ws.send(result)
                    case .failure(let error):
                        print(error)
                        ws.send(UserError.defaultError)
                    }
                }
            }
        }
    }

}
