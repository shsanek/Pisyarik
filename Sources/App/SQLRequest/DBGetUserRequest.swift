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
        self.request = "SELECT \(DBUserRaw.sqlGET()) FROM user WHERE name LIKE BINARY '%\(name)%' LIMIT 50;"
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

struct DBGetTokenUserRequest: IDBRequest {
    typealias Result = DBContainer2<DBUserRaw, DBTokenRaw>

    let description: String
    let request: String

    init(token: String) {
        self.description = "Get user with token '\(token)'"
        self.request = """
            SELECT
                \(DBUserRaw.sqlGET()),
                \(DBTokenRaw.sqlGET)
            FROM token, user
            WHERE token.user_id = user.identifier AND token.token = '\(token)';
        """
    }
}

struct DBApnsTokenRequest: IDBRequest {

    let description: String
    let request: String

    init(token: String) {
        self.description = "Get apns token"
        self.request = """
            SELECT
                token.apns_token as identifier
            FROM token
            WHERE token.token = \(token);
        """
    }

    struct Result: Codable {
        let identifier: String?
    }
}

struct DBGetUserTokenRequest: IDBRequest {

    let description: String
    let request: String

    init(userId: IdentifierType) {
        self.description = "Get apns token"
        self.request = """
            SELECT
                token.token as identifier
            FROM token
            WHERE token.user_id = \(userId);
        """
    }

    struct Result: Codable {
        let identifier: String
    }
}
