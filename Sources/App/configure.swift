import Vapor

// configures your application
public func configure(_ app: Application) throws {
    let dataBase = DataBase(app)
    try? dataBase.migration(versions: []).make(app.eventLoopGroup.next()).wait()

    let rootRouter = RootRouter(dataBase: dataBase, app: app)
    rootRouter.registration(handler: CheckHandler())

    rootRouter.registration(handler: UserLoginHandler())
    rootRouter.registration(handler: UserRegistrationHandler())
    rootRouter.registration(handler: UserSearchHandler())
    rootRouter.registration(handler: UserGetSelfHandler())
    rootRouter.registration(handler: UserUpdateSelfHandler())
    rootRouter.registration(handler: UserLogoutHandler())
    rootRouter.registration(handler: UserSetApnsHandler())

    rootRouter.registration(handler: MessageGetFromChat())
    rootRouter.registration(handler: MessageSendHandler())
    rootRouter.registration(handler: MessageSetReadMark())

    rootRouter.registration(handler: ChatAddUserHandler())
    rootRouter.registration(handler: ChatMakeHandler())
    rootRouter.registration(handler: ChatGetUsersHandler())
    rootRouter.registration(handler: ChatGetAllMyHandler())
    rootRouter.registration(handler: ChatMakePersonalHandler())

    rootRouter.registration(handler: UpdateGetHandler())

    app.get("**".pathComponents) { _ in
        return UserError.notFoundError
    }
    app.post("**".pathComponents) { _ in
        return UserError.notFoundError
    }
    app.post { _ in
        return UserError.notFoundError
    }
    app.get { _ in
        return UserError.notFoundError
    }

    rootRouter.activeWebSocket()
}
