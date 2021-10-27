import Vapor

final class RootRouter {
    private let dataBase: IDataBase
    private weak var app: Application?

    init(dataBase: IDataBase, app: Application) {
        self.dataBase = dataBase
        self.app = app
    }

    func registration<Handler: IRequestHandler>(handler: Handler) {
        let container = RequestHandlerContainer(handler: handler)
        app?.get(handler.name.pathComponents) { request in
            return container.handle(request, dataBase: self.dataBase)
        }
        app?.post(handler.name.pathComponents) { request in
            return container.handle(request, dataBase: self.dataBase)
        }
    }
}
