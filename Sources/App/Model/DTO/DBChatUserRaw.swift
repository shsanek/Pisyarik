struct DBChatUserRaw: Codable {
    let chat_user_last_read_message_id: IdentifierType
    let chat_user_not_read_message_count: Int
}

extension DBChatUserRaw {
    static var sqlGET: String {
        let sql = """
                chat_user.last_read_message_id as chat_user_last_read_message_id,
                chat_user.not_read_message_count as chat_user_not_read_message_count
            """
        return sql
    }
}
