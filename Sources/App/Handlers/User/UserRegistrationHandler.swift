import PromiseKit

struct UserRegistrationHandler: IRequestHandler {
    var name: String {
        "user/registration"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<EmptyRaw> {
        guard parameters.authorisationInfo == nil else {
            return .init(error: UserError.alreadyLogin)
        }
        guard parameters.input.name.count < 40 else {
            return .init(error: UserError.incorrectName)
        }
        return dataBase.run(request: DBGetUserRequest(name: parameters.input.name)).map { result -> Void in
            if result.count != 0 {
                throw UserError.nameAlreadyRegistry
            }
            return Void()
        }.then { _ in
            dataBase.run(request: DBMakeUserWithNameRequest(name: parameters.input.name))
        }.map { _ in
            EmptyRaw()
        }
    }
}

extension UserRegistrationHandler {
    struct Input: Codable {
        let name: String
    }
}
