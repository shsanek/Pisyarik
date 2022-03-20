struct DBGetChatRequest: IDBRequest {
    typealias Result = DBContainer5<DBChatRaw, DBMessageRaw, DBUserRaw, DBPersonalNameRaw, DBChatUserRaw>

    let description: String
    let request: String
}

extension DBGetChatRequest {
    init(userId: IdentifierType, personalChatName: String? = nil) {
        self.description = "Get chat with user id '\(userId)'"
        self.request = """
            SELECT
                   \(DBUserRaw.sqlGET()),
                   \(DBMessageRaw.sqlGET),
                   \(DBChatRaw.sqlGET),
                   \(DBPersonalNameRaw.sqlGET),
                   \(DBChatUserRaw.sqlGET)
            from chat
                    INNER JOIN chat_user
                    ON
                        chat.identifier = chat_user.chat_id AND
                        chat_user.user_id = \(userId)
                        \(personalChatName.flatMap { "AND chat.name = '\($0)'" } ?? "")

                    INNER JOIN message
                    ON chat.last_message_id = message.identifier

                    INNER JOIN user
                    ON message.user_id = user.identifier

                    LEFT JOIN chat_user as personal_chat_user
                    ON
                        chat.identifier = personal_chat_user.chat_id AND
                        chat.type = "personal" AND
                        personal_chat_user.user_id <> \(userId)

                    LEFT JOIN user as personal_user
                    ON personal_user.identifier = personal_chat_user.user_id
            ;
            """
    }

    init(chatId: IdentifierType, userId: IdentifierType) {
        self.description = "Get chats with id '\(chatId)' for user \(userId)"
        self.request = """
            SELECT
                \(DBUserRaw.sqlGET()),
                \(DBMessageRaw.sqlGET),
                \(DBChatRaw.sqlGET),
                \(DBPersonalNameRaw.sqlGET),
                \(DBChatUserRaw.sqlGET)
            from chat
                    INNER JOIN chat_user
                    ON
                        chat.identifier = chat_user.chat_id AND
                        chat_user.user_id = \(userId) AND
                        chat.identifier = \(chatId)

                    INNER JOIN message
                    ON chat.last_message_id = message.identifier

                    INNER JOIN user
                    ON message.user_id = user.identifier

                    LEFT JOIN chat_user as personal_chat_user
                    ON
                        chat.identifier = personal_chat_user.chat_id AND
                        chat.type = "personal" AND
                        personal_chat_user.user_id <> \(userId)

                    LEFT JOIN user as personal_user
                    ON personal_user.identifier = personal_chat_user.user_id
            ;
            """
    }
}

struct DBGetLightChatRequest: IDBRequest {
    typealias Result = DBChatRaw

    let description: String
    let request: String

    init(name: String) {
        self.description = "Get chats with name = '\(name)'"
        self.request = "SELECT \(DBChatRaw.sqlGET) FROM chat WHERE name = '\(name)';"
    }

    init(contains name: String) {
        self.description = "Get chats with name contains '\(name)'"
        self.request = "SELECT \(DBChatRaw.sqlGET) FROM chat WHERE name LIKE BINARY '%\(name)%';"
    }

    init(chatId: IdentifierType) {
        self.description = "Get chats with id '\(chatId)'"
        self.request = "SELECT \(DBChatRaw.sqlGET) FROM chat WHERE identifier = \(chatId);"
    }
}
