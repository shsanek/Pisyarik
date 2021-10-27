struct DBAddMessageRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Add new message"
    }
    var request: String {
        "INSERT INTO message(user_id, chat_id, body, date, type) VALUES (\(message.author_id), \(message.chat_id), '\(message.body)', \(message.date), '\(message.type)');"
    }
    
    let message: DBMessageRaw
}
