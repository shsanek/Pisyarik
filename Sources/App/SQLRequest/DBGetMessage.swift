struct DBGetMessage: IDBRequest {
    typealias Result = DBContainer<DBFullMessageRaw>

    let description: String
    let request: String
}

extension DBGetMessage {
    init(limit: Int, chatId: IdentifierType, lastMessage: IdentifierType?) {
        self.description = "Get message"
        let addedСondition = lastMessage.flatMap { "AND identifier < \($0)" } ?? ""
        let getMessages = "(SELECT * FROM message WHERE chat_id = \(chatId) \(addedСondition) ORDER BY identifier DESC LIMIT \(limit))"
        self.request = "SELECT message.user_id as author_id, user.name as author_name, message.chat_id as chat_id, message.body as body, message.date as date, message.type as type, message.identifier as identifier FROM \(getMessages) as message, user WHERE message.user_id = user.identifier"
    }
}
