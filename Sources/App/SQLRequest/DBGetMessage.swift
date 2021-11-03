struct DBGetMessage: IDBRequest {
    typealias Result = DBContainer2<DBUserRaw, DBMessageRaw>

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
                \(DBUserRaw.sqlGET()),
                \(DBMessageRaw.sqlGET)
            FROM \(getMessages) as message, user
            WHERE message.user_id = user.identifier
            ORDER BY message_id \(sort)
            """
    }
    
    init(messageId: IdentifierType) {
        self.description = "Get message"
        self.request = """
            SELECT
                \(DBUserRaw.sqlGET()),
                \(DBMessageRaw.sqlGET)
            FROM message, user
            WHERE message.user_id = user.identifier AND message.identifier = \(messageId)
            ;
            """
    }
}
