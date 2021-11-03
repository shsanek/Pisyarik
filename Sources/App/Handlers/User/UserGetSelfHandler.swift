import PromiseKit

struct UserGetSelfHandler: IRequestHandler {
    var name: String {
        "user/get_self"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> Promise<UserOutput> {
        parameters.getUser.map { UserOutput($0.user, authorisationInfo: $0) }
    }
}
