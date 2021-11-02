struct DBAddMessageRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new message"
    }
    var request: String {
        """
        INSERT INTO message(user_id, chat_id, body, date, type)
        VALUES (\(message.author_id), \(message.chat_id), '\(message.body)', \(message.date), '\(message.type)');

        SET @last_identifier = LAST_INSERT_ID ();

        UPDATE chat_user SET not_read_message_count = not_read_message_count + 1
        WHERE chat_id = \(message.chat_id) AND user_id <> \(message.author_id);

        UPDATE chat_user SET not_read_message_count = 0, last_read_message_id = @last_identifier
        WHERE chat_id = \(message.chat_id) AND user_id = \(message.author_id);

        UPDATE chat SET last_message_id = @last_identifier WHERE identifier = \(message.chat_id);
        SELECT @last_identifier as identifier;
        """
    }

    let message: DBMessageRaw
}
