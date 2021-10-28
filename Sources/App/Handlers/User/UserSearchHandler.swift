import PromiseKit

struct UserSearchHandler: IRequestHandler {
    var name: String {
        "user/search"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<UsersOutput> {
        parameters.onlyLogin.then { parameters in
            dataBase.run(request: DBGetUserRequest(contains: parameters.input.name))
        }.map { result in
            UsersOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension UserSearchHandler {
    struct Input: Codable {
        let name: String
    }
}
