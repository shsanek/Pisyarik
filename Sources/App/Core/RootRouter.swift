import Vapor

final class RootRouter {
    private let dataBase: IDataBase
    private let app: Application
    private lazy var updateCenter = UpdateCenter(dataBase: dataBase, app: app)

    init(dataBase: IDataBase, app: Application) {
        self.dataBase = dataBase
        self.app = app
    }

    func registration<Handler: IRequestHandler>(handler: Handler) {
        let container = RequestHandlerContainer(handler: handler)
        app.get(handler.name.pathComponents) { request in
            return container.handle(request, dataBase: self.dataBase, updateCenter: self.updateCenter)
        }
        app.post(handler.name.pathComponents) { request in
            return container.handle(request, dataBase: self.dataBase, updateCenter: self.updateCenter)
        }
    }
}
