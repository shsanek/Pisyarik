import PromiseKit

struct UserLogoutHandler: IRequestHandler {
    var name: String {
        "user/logout"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> Promise<EmptyRaw> {
        parameters.getUser.then {
            dataBase.run(request: DBRemoveToken(token: $0.token))
        }.map { _ in
            EmptyRaw()
        }
    }
}
