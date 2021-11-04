import Foundation

struct UserLoginHandler: IRequestHandler {
    var name: String {
        "user/login"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<Output> {
        guard parameters.authorisationInfo == nil else {
            throw Errors.alreadyLogin.description(
                "Пользователь уже авторизирован почисти авторизационные токены"
            )
        }
        let key = try Errors.loginErrors.handle("Неудаеться сгенерить семетричный ключ") {
            try CryptoUtils.generateKey(userPublicKey: parameters.input.userPublicKey)
        }
        return firstly {
            dataBase.run(request: DBGetUserRequest(name: parameters.input.name))
        }.first().handle { user in
            guard user.user_security_hash == String(parameters.input.securityHash.prefix(64)) else {
                throw Errors.loginErrors.description("Неправильный security_hash")
            }
        }.then { user in
            dataBase.run(
                request: DBAddTokenForUserRequest(
                    token: DBTokenRaw(
                        token_token: key.uuid,
                        token_secret_key: String(key.symmetricKey),
                        token_user_id: user.user_id,
                        token_apns_token: nil
                    )
                )
            ).map { _ in
                (userId: user.user_id, publicKey: key.publicKey)
            }
        }.map { result in
            Output(
                token: key.uuid,
                serverPublicKey: result.publicKey,
                userId: result.userId
            )
        }.mapError { error in
            var error = UserError(error)
            error.code = Errors.loginErrors.rawValue
            return error
        }
    }
}

extension UserLoginHandler {
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
