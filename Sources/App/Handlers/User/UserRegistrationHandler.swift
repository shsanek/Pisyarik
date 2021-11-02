import PromiseKit

struct UserRegistrationHandler: IRequestHandler {
    var name: String {
        "user/registration"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        guard parameters.authorisationInfo == nil else {
            throw Errors.alreadyLogin.description(
                "Пользователь уже авторизирован почисти авторизационные токены"
            )
        }
        guard parameters.input.name.count < 40 else {
            throw Errors.incorrectName.description(
                "Неправильное имя проверь ограничения сейчас < 40"
            )
        }
        let key = try Errors.internalError.handle(
            "Неудаеться сгенерить семетричный ключ"
        ) {
            try CryptoUtils.generateKey(userPublicKey: parameters.input.userPublicKey)
        }

        return dataBase.run(request: DBGetUserRequest(name: parameters.input.name)).handler { result in
            if result.count != 0 {
                throw Errors.alreadyLogin.description("Пользователь с таким именем уже существует")
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
