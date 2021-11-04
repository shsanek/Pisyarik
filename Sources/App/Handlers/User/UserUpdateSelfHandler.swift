struct UserUpdateSelfHandler: IRequestHandler {
    var name: String {
        "user/update_self"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<EmptyRaw> {
        parameters.getUser.map { $0.user }.map { user in
            dataBase.run(
                request: DBUpdateUserRequest(
                    user: .init(
                        user_id: user.user_id,
                        user_name: user.user_name,
                        user_security_hash: nil,
                        user_first_name: parameters.input.firstName ?? user.user_first_name,
                        user_last_name: parameters.input.lastName ?? user.user_last_name,
                        user_background_hex: parameters.input.hex ?? user.user_background_hex,
                        user_emoji: parameters.input.emoji ?? user.user_emoji
                    )
                )
            )
        }.map { _ in
            EmptyRaw()
        }
    }
}

extension UserUpdateSelfHandler {
    struct Input: Codable {
        let hex: String?
        let emoji: String?
        let firstName: String?
        let lastName: String?
    }
}
