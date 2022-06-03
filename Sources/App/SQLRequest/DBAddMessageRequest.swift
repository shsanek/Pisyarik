struct DBAddMessageRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new message"
    }

    func request() throws -> String {
        """
        INSERT INTO message(user_id, chat_id, body, date, type)
        VALUES (
            \(message.message_author_id),
            \(message.message_chat_id),
            '\(try message.message_body.safe())',
            \(message.message_date),
            '\(try message.message_type.safe())'
        );

        SET @last_identifier = LAST_INSERT_ID ();

        UPDATE chat_user SET not_read_message_count = not_read_message_count + 1
        WHERE chat_id = \(message.message_chat_id) AND user_id <> \(message.message_author_id);

        UPDATE chat_user SET not_read_message_count = 0, last_read_message_id = @last_identifier
        WHERE chat_id = \(message.message_chat_id) AND user_id = \(message.message_author_id);

        UPDATE chat SET last_message_id = @last_identifier WHERE identifier = \(message.message_chat_id);
        SELECT @last_identifier as identifier;
        """
    }

    let message: DBMessageRaw
}
