import PromiseKit
import Foundation

struct UserLoginHandler: IRequestHandler {
    var name: String {
        "user/login"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        guard parameters.authorisationInfo == nil else {
            return .init(error: UserError.alreadyLogin)
        }
        let result = Promise<Output>.pending()
        guard
            let key = try? CryptoUtils.generateKey(userPublicKey: parameters.input.userPublicKey)
        else {
            return .init(error: UserError.loginError)
        }
        dataBase
            .run(request: DBGetUserRequest(name: parameters.input.name))
            .firstValue
            .handler { user in
                guard user.content.security_hash == String(parameters.input.securityHash.prefix(64)) else {
                    throw UserError.loginError
                }
            }
            .then { user in
                return dataBase.run(
                    request: DBAddTokenForUserRequest(
                        token: DBTokenRaw(
                            token: key.uuid,
                            secret_key: String(key.symmetricKey),
                            user_id: user.identifier
                        )
                    )
                ).map { _ in
                    return (userId: user.identifier, publicKey: key.publicKey)
                }
            }.map { result in
                return Output(
                    token: key.uuid,
                    serverPublicKey: result.publicKey,
                    userId: result.userId
                )
            }.done { output in
                result.resolver.fulfill(output)
            }.catch { error in
                print(error)
                result.resolver.reject(UserError.loginError)
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


extension UserError {
    static var loginError: UserError {
        UserError(name: "Login error", description: "Login error", info: nil)
    }
}
