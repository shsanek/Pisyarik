struct UsersOutput: Codable {
    struct User: Codable {
        let name: String
        let userId: IdentifierType
        let isSelf: Bool
    }
    
    let users: [User]
}

extension UsersOutput {
    init(_ users: [DBContainer<DBUserRaw>], authorisationInfo: AuthorisationInfo?){
        self = UsersOutput(
            users: users.map {
                UsersOutput.User(
                    name: $0.content.name,
                    userId: $0.identifier,
                    isSelf: authorisationInfo?.identifier == $0.identifier
                )
            }
        )
    }
}

struct ChatsOutput: Codable {
    struct Chat: Codable {
        let name: String
        let chatId: IdentifierType
        let message: MessagesOutput.Message?
    }
    
    let chats: [Chat]
}

extension ChatsOutput {
    init(_ chats: [DBContainer2<DBChatRaw, DBFullMessageRaw>], authorisationInfo: AuthorisationInfo?){
        self = ChatsOutput(
            chats: chats.map {
                ChatsOutput.Chat(
                    name: $0.content1.name,
                    chatId: $0.identifier,
                    message: $0.content2.flatMap { MessagesOutput.Message($0, authorisationInfo: authorisationInfo) }
                )
            }
        )
    }
}

struct MessagesOutput: Codable {
    struct Message: Codable {
        let user: UsersOutput.User
        let date: UInt
        let body: String
        let type: String
        let messageId: IdentifierType
        let chatId: IdentifierType
    }
    let messages: [Message]
}

extension MessagesOutput.Message {
    init(_ raw: DBFullMessageRaw, authorisationInfo: AuthorisationInfo?) {
        self = MessagesOutput.Message(
            user: .init(
                name: raw.author_name,
                userId: raw.author_id,
                isSelf: authorisationInfo?.identifier == raw.author_id
            ),
            date: raw.date,
            body: raw.body,
            type: raw.type,
            messageId: raw.message_id,
            chatId: raw.chat_id
        )
    }
}
extension MessagesOutput {
    init(_ raw: [DBFullMessageRaw], authorisationInfo: AuthorisationInfo?) {
        self.messages = raw.map { raw in
            return .init(raw, authorisationInfo: authorisationInfo)
        }
    }
}
