struct DBGetChatRequest: IDBRequest {
    typealias Result = DBContainer2<DBChatRaw, DBFullMessageRaw>

    let description: String
    let request: String
}

extension DBGetChatRequest {
    init(userId: IdentifierType) {
        self.description = "Get chat with user id '\(userId)'"
        self.request = "SELECT chat.identifier as identifier, chat.name as name, message.user_id as author_id, user.name as author_name, message.chat_id as chat_id, message.body as body, message.date as date, message.type as type, message.identifier as message_id FROM chat_user, chat, message, user WHERE chat_user.user_id = \(userId) AND chat_user.chat_id = chat.identifier AND message.identifier = chat.last_message_id AND user.identifier = message.user_id;"
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
