import PromiseKit

struct UserRegistrationHandler: IRequestHandler {
    var name: String {
        "user/registration"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        guard parameters.authorisationInfo == nil else {
            return .init(error: UserError.alreadyLogin)
        }
        guard parameters.input.name.count < 40 else {
            return .init(error: UserError.incorrectName)
        }
        guard
            let key = try? CryptoUtils.generateKey(userPublicKey: parameters.input.userPublicKey)
        else {
            return .init(error: UserError.loginError)
        }
        return dataBase.run(request: DBGetUserRequest(name: parameters.input.name)).handler { result in
            if result.count != 0 {
                throw UserError.nameAlreadyRegistry
            }
        }.then { _ in
            dataBase.run(
                request: DBAddUserWithNameRequest(
                    name: parameters.input.name,
                    securityHash: String(parameters.input.securityHash.prefix(64))
                )
            )
        }.only.then { identifier in
            return dataBase.run(
                request: DBAddTokenForUserRequest(
                    token: DBTokenRaw(
                        token: key.uuid,
                        secret_key: String(key.symmetricKey),
                        user_id: identifier.identifier
                    )
                )
            ).map { _ in
                return (userId: identifier.identifier, publicKey: key.publicKey)
            }
        }.map { result in
            return Output(
                token: key.uuid,
                serverPublicKey: result.publicKey,
                userId: result.userId
            )
        }
    }
}

extension UserRegistrationHandler {
    struct Input: Codable {
        let name: String
        let securityHash: String
        let userPublicKey: String
    }
    
    struct Output: Codable {
        let token: String
        let serverPublicKey: String
        let userId: IdentifierType
    }
}
