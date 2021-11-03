struct MessageOutput: Codable {
    let user: UserOutput
    let date: UInt
    let content: String
    let type: String
    let messageId: IdentifierType
    let chatId: IdentifierType
}

extension MessageOutput {
    init(
        _ raw: DBContainer2<DBUserRaw, DBMessageRaw>,
        authorisationInfo: AuthorisationInfo?
    ) {
        self.user = UserOutput(raw.content1, authorisationInfo: authorisationInfo)
        self.date = raw.content2.message_date
        self.messageId = raw.content2.message_id
        self.content = raw.content2.message_body
        self.type = raw.content2.message_type
        self.chatId = raw.content2.message_chat_id
    }
}

struct MessageListOutput: Codable {
    let messages: [MessageOutput]
}

extension MessageListOutput {
    init(
        _ raws: [DBContainer2<DBUserRaw, DBMessageRaw>],
        authorisationInfo: AuthorisationInfo?
    ) {
        self.messages = raws.map {
            MessageOutput($0, authorisationInfo: authorisationInfo)
        }
    }
}
