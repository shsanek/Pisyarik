struct DBGetUserRequest: IDBRequest {
    typealias Result = DBContainer<DBUserRaw>

    let description: String
    let request: String
}

extension DBGetUserRequest {
    init(name: String) {
        self.description = "Get user with name '\(name)'"
        self.request = "SELECT * FROM user WHERE name = '\(name)';"
    }
    
    init(userId: IdentifierType) {
        self.description = "Get user with name '\(userId)'"
        self.request = "SELECT * FROM user WHERE identifier = \(userId);"
    }
    
    init(token: String) {
        self.description = "Get user with token '\(token)'"
        self.request = """
            SELECT user.identifier as identifier, user.name as name, token.secret_key as secret_key
            FROM token, user
            WHERE token.user_id = user.identifier AND token.token = '\(token)';
        """
    }
    
    init(contains name: String) {
        self.description = "Get users with name contains '\(name)'"
        self.request = "SELECT * FROM user WHERE name LIKE BINARY '%\(name)%' LIMIT 50;"
    }
    
    init(chatId: IdentifierType) {
        self.description = "Get users in chat id '\(chatId)'"
        self.request = "SELECT user.identifier as identifier, user.name as name FROM chat_user, user WHERE chat_user.user_id = user.identifier AND chat_user.chat_id = \(chatId);"
    }
}
