struct DBUpdateReadMessageRequest: IDBRequest {
    typealias Result = DBCountRaw

    var description: String {
        "Update read message"
    }
    var request: String {
        """
        SET @last_update_count = (SELECT COUNT(*) FROM message, chat_user WHERE chat_user.chat_id = \(chatId) AND chat_user.user_id = \(userId) AND message.identifier > chat_user.last_read_message_id AND message.identifier <= \(messageId));

        UPDATE chat_user SET not_read_message_count = not_read_message_count - @last_update_count, last_read_message_id = \(messageId) WHERE chat_id = \(chatId) AND user_id = \(userId);
        SELECT not_read_message_count as count FROM chat_user WHERE chat_id = \(chatId) AND user_id = \(userId);
        """
    }
    
    let messageId: IdentifierType
    let chatId: IdentifierType
    let userId: IdentifierType
}
