struct DBMessageRaw: Codable {
    let message_author_id: IdentifierType
    let message_chat_id: IdentifierType
    let message_date: UInt
    let message_body: String
    let message_type: String
    let message_id: IdentifierType
}

extension DBMessageRaw {
    static var sqlGET: String {
        let sql = """
            message.user_id as message_author_id,
            message.chat_id as message_chat_id,
            message.date as message_date,
            message.body as message_body,
            message.type as message_type,
            message.identifier as message_id
            """
        return sql
    }
}
