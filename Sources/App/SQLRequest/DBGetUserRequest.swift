struct DBGetUserRequest: IDBRequest {
    typealias Result = DBUserRaw

    let description: String
    let request: String
}

extension DBGetUserRequest {
    init(name: String) {
        self.description = "Get user with name '\(name)'"
        self.request = "SELECT \(DBUserRaw.sqlGET(true)) FROM user WHERE name = '\(name)';"
    }

    init(userId: IdentifierType) {
        self.description = "Get user with name '\(userId)'"
        self.request = "SELECT \(DBUserRaw.sqlGET()) FROM user WHERE identifier = \(userId);"
    }

    init(contains name: String) {
        self.description = "Get users with name contains '\(name)'"
        self.request = "SELECT \(DBUserRaw.sqlGET()) FROM user WHERE LOWER(name) LIKE '%\(name.lowercased())%' LIMIT 50;"
    }

    init(chatId: IdentifierType) {
        self.description = "Get users in chat id '\(chatId)'"
        self.request = """
            SELECT
                \(DBUserRaw.sqlGET())
            FROM chat_user, user
            WHERE
                chat_user.user_id = user.identifier AND
                chat_user.chat_id = \(chatId);
            """
    }
}
