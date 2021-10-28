struct DBAddMessageRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new message"
    }
    var request: String {
        """
        INSERT INTO message(user_id, chat_id, body, date, type) VALUES (\(message.author_id), \(message.chat_id), '\(message.body)', \(message.date), '\(message.type)');
        SET @last_identifier = LAST_INSERT_ID ();
        UPDATE chat SET last_message_id = @last_identifier WHERE identifier = \(message.chat_id);
        SELECT @last_identifier as identifier;
        """
    }
    
    let message: DBMessageRaw
}
