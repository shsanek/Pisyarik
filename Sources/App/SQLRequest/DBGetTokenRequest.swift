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

struct DBGetTokenRequest: IDBRequest {
    
    typealias Result = DBShortTokenRaw

    let description: String
    let request: String

    init(token: String) {
        self.description = "Get apns token"
        self.request = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM token
            WHERE token.token = '\(token)';
        """
    }
    
    init(userId: IdentifierType) {
        self.description = "Get all tokens"
        self.request = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM token
            WHERE token.user_id = \(userId);
        """
    }
    
    init(chatId: IdentifierType) {
        self.description = "Get all tokens for chats"
        self.request = """
            SELECT
                \(DBShortTokenRaw.sqlGET)
            FROM chat_user, token
            WHERE
                chat_user.user_id = token.user_id AND
                chat_user.chat_id = \(chatId);
            """
    }
}
