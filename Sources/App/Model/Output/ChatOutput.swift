struct ChatOutput: Codable {
    let name: String
    let chatId: IdentifierType
    let type: ChatType
    let message: MessageOutput?
    let lastMessageId: IdentifierType?
    let notReadCount: Int?
}

extension ChatOutput {
    init(
        _ raw: DBContainer5<DBChatRaw, DBMessageRaw, DBUserRaw, DBPersonalNameRaw, DBChatUserRaw>,
        authorisationInfo: AuthorisationInfo?
    ) {
        self.message = MessageOutput(
            DBContainer2(
                content1: raw.content3,
                content2: raw.content2
            ),
            authorisationInfo: authorisationInfo
        )
        self.name = raw.content4.personal_user_name ?? raw.content1.chat_name
        self.type = ChatType(rawValue: raw.content1.chat_type) ?? .unknown
        self.lastMessageId = raw.content5.chat_user_last_read_message_id
        self.notReadCount = raw.content5.chat_user_not_read_message_count
        self.chatId = raw.content1.chat_id
    }

    init(
        _ raw: DBChatRaw
    ) {
        self.message = nil
        self.name = raw.chat_name
        self.type = ChatType(rawValue: raw.chat_type) ?? .unknown
        self.lastMessageId = nil
        self.notReadCount = nil
        self.chatId = raw.chat_id
    }
}

struct ChatListOutput: Codable {
    let chats: [ChatOutput]
}

extension ChatListOutput {
    init(
        _ raws: [DBContainer5<DBChatRaw, DBMessageRaw, DBUserRaw, DBPersonalNameRaw, DBChatUserRaw>],
        authorisationInfo: AuthorisationInfo?
    ) {
        self.chats = raws.map {
            ChatOutput($0, authorisationInfo: authorisationInfo)
        }
    }

    init(_ raws: [DBChatRaw]) {
        self.chats = raws.map {
            ChatOutput($0)
        }
    }
}
