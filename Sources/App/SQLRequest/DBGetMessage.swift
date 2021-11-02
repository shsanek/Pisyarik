struct DBGetMessage: IDBRequest {
    typealias Result = DBFullMessageRaw

    let description: String
    let request: String
}

extension DBGetMessage {
    init(limit: Int, chatId: IdentifierType, lastMessage: IdentifierType?, reverse: Bool) {
        self.description = "Get message"
        let sort = reverse ? "ASC" : "DESC"
        let addedCondition = lastMessage.flatMap { "AND identifier \(reverse ? ">" : "<") \($0)" } ?? ""
        let getMessages = """
            (SELECT * FROM message
            WHERE chat_id = \(chatId) \(addedCondition)
            ORDER BY identifier \(sort) LIMIT \(limit))
            """
        self.request = """
            SELECT
                message.user_id as author_id,
                user.name as author_name,
                message.chat_id as chat_id,
                message.body as body,
                message.date as date,
                message.type as type,
                message.identifier as message_id
            FROM \(getMessages) as message, user
            WHERE message.user_id = user.identifier
            ORDER BY message_id \(sort)
            """
    }
}
