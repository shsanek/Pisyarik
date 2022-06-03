struct DBGetUserRequest: IDBRequest {
    typealias Result = DBUserRaw

    let description: String
    private let sql: String

    func request() throws -> String {
        return sql
    }
}

extension DBGetUserRequest {
    init(name: String) throws {
        self.description = "Get user with name '\(name)'"
        self.sql = "SELECT \(DBUserRaw.sqlGET(true)) FROM user WHERE name = '\(try name.safe())';"
    }

    init(userId: IdentifierType) {
        self.description = "Get user with name '\(userId)'"
        self.sql = "SELECT \(DBUserRaw.sqlGET()) FROM user WHERE identifier = \(userId);"
    }

    init(contains name: String) throws {
        self.description = "Get users with name contains '\(try name.safe())'"
        self.sql = "SELECT \(DBUserRaw.sqlGET()) FROM user WHERE LOWER(name) LIKE '%\(name.lowercased())%' LIMIT 50;"
    }

    init(chatId: IdentifierType) {
        self.description = "Get users in chat id '\(chatId)'"
        self.sql = """
            SELECT
                \(DBUserRaw.sqlGET())
            FROM chat_user, user
            WHERE
                chat_user.user_id = user.identifier AND
                chat_user.chat_id = \(chatId);
            """
    }
}
