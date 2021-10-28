struct DBAddUserInChatRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add user in chat"
    }
    var request: String {
        "INSERT INTO chat_user(user_id, chat_id) VALUES (\(userId), \(chatId)); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let userId: IdentifierType
    let chatId: IdentifierType
}
