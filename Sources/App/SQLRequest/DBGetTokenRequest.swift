struct DBGetTokenUserRequest: IDBRequest {
    typealias Result = DBContainer2<DBUserRaw, DBTokenRaw>

    let description: String
    private let sql: String

    func request() throws -> String {
        return sql
    }

    init(token: String) throws {
        self.description = "Get user with token '\(token)'"
        self.sql = """
            SELECT
                \(DBUserRaw.sqlGET()),
                \(DBTokenRaw.sqlGET)
            FROM token, user
            WHERE token.user_id = user.identifier AND token.token = '\(try token.safe())';
        """
    }
}

struct DBGetTokenRequest: IDBRequest {
    
    typealias Result = DBShortTokenRaw

    let description: String
    private let sql: String

    func request() throws -> String {
        return sql
    }

    init(token: String) throws {
        self.description = "Get apns token"
        self.sql = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM token
            WHERE token.token = '\(try token.safe())';
        """
    }
    
    init(userId: IdentifierType) {
        self.description = "Get all tokens"
        self.sql = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM token
            WHERE token.user_id = \(userId);
        """
    }
    
    init(chatId: IdentifierType) {
        self.description = "Get all tokens for chats"
        self.sql = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM chat_user, token
            WHERE
                chat_user.user_id = token.user_id AND
                chat_user.chat_id = \(chatId);
            """
    }
}
