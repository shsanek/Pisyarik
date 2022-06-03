struct UserSearchHandler: IRequestHandler {
    var name: String {
        "user/search"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<UserListOutput> {
        parameters.onlyLogin.then { parameters in
            dataBase.run(request: try DBGetUserRequest(contains: parameters.input.name))
        }.map { result in
            UserListOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension UserSearchHandler {
    struct Input: Codable {
        let name: String
    }
}
