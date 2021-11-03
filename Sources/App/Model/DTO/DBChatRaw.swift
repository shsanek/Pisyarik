struct DBChatRaw: Decodable {
    let chat_id: IdentifierType
    let chat_name: String
    let chat_type: String
}

extension DBChatRaw {
    static var sqlGET: String {
        let sql = """
            chat.name as chat_name,
            chat.identifier as chat_id,
            chat.type as chat_type
            """
        return sql
    }
}
