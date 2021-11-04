final class UserSetApnsHandler: IRequestHandler {
    var name: String {
        "user/set_apns_token"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<EmptyRaw> {
        parameters.getUser.map { aut in
            dataBase.run(
                request: DBUpdateApnsRequest(
                    apnsToken: parameters.input.token,
                    token: aut.token
                )
            )
        }.map { _ in
            EmptyRaw()
        }
    }
}

extension UserSetApnsHandler {
    struct Input: Codable {
        let token: String
    }
}
