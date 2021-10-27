struct DBAddUserInChatRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Add user in chat"
    }
    var request: String {
        "INSERT INTO chat_user(user_id, chat_id) VALUES (\(userId), \(chatId));"
    }
    
    let userId: IdentifierType
    let chatId: IdentifierType
}
