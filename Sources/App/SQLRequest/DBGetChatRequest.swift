struct DBGetChatRequest: IDBRequest {
    typealias Result = DBContainer<DBChatRaw>

    let description: String
    let request: String
}

extension DBGetChatRequest {
    init(userId: IdentifierType) {
        self.description = "Get chat with user id '\(userId)'"
        self.request = "SELECT chat.identifier as identifier, chat.name as name FROM chat_user, chat WHERE chat_user.user_id = \(userId) AND chat_user.chat_id = chat.identifier;"
    }
    
    init(name: String) {
        self.description = "Get chats with name = '\(name)'"
        self.request = "SELECT * FROM chat WHERE name = '\(name)';"
    }

    init(contains name: String) {
        self.description = "Get chats with name contains '\(name)'"
        self.request = "SELECT * FROM chat WHERE name LIKE BINARY '%\(name)%';"
    }
}
