struct UsersOutput: Codable {
    struct User: Codable {
        let name: String
        let userId: IdentifierType
    }
    
    let users: [User]
}

extension UsersOutput {
    init(_ users: [DBContainer<DBUserRaw>]){
        self = UsersOutput(
            users: users.map {
                UsersOutput.User(
                    name: $0.content.name,
                    userId: $0.identifier
                )
            }
        )
    }
}

struct ChatsOutput: Codable {
    struct Chat: Codable {
        let name: String
        let chatId: IdentifierType
    }
    
    let chats: [Chat]
}

extension ChatsOutput {
    init(_ chats: [DBContainer<DBChatRaw>]){
        self = ChatsOutput(
            chats: chats.map {
                ChatsOutput.Chat(
                    name: $0.content.name,
                    chatId: $0.identifier
                )
            }
        )
    }
}

