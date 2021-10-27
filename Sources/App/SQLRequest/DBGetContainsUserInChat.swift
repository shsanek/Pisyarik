struct DBGetContainsUserInChat: IDBRequest {
    typealias Result = DBCountRaw

    let description: String
    let request: String
}

extension DBGetContainsUserInChat {
    init(userId: IdentifierType, chatId: IdentifierType) {
        self.description = "Get contains user in chat"
        self.request = "SELECT COUNT(*) as count FROM chat_user WHERE user_id = \(userId) AND chat_id = \(chatId);"
    }
}
