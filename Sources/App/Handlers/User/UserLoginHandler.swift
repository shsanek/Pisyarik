import PromiseKit
import Foundation

struct UserLoginHandler: IRequestHandler {
    var name: String {
        "user/login"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        guard parameters.authorisationInfo == nil else {
            throw Errors.alreadyLogin.description(
                "Пользователь уже авторизирован почисти авторизационные токены"
            )
        }
        let result = Promise<Output>.pending()

        let key = try Errors.loginErrors.handle("Неудаеться сгенерить семетричный ключ") {
            try CryptoUtils.generateKey(userPublicKey: parameters.input.userPublicKey)
        }
        firstly {
            dataBase.run(request: DBGetUserRequest(name: parameters.input.name))
        }.firstValue.handler { user in
            guard user.user_security_hash == String(parameters.input.securityHash.prefix(64)) else {
                throw Errors.loginErrors.description("Неправильный security_hash")
            }
        }
        .then { user in
            dataBase.run(
                request: DBAddTokenForUserRequest(
                    token: DBTokenRaw(
                        token_token: key.uuid,
                        token_secret_key: String(key.symmetricKey),
                        token_user_id: user.user_id
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
        }.done { output in
            result.resolver.fulfill(output)
        }.catch { error in
            var error = UserError(error)
            error.code = Errors.loginErrors.rawValue
            result.resolver.reject(error)
        }
        return result.promise
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
