struct DBAddUserInChatRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add user in chat"
    }
    var request: String {
        """
        SET @last_message_id = (SELECT last_message_id as id FROM chat WHERE identifier = \(chatId));
        INSERT INTO chat_user(user_id, chat_id, last_read_message_id) VALUES (\(userId), \(chatId), @last_message_id);
        SELECT LAST_INSERT_ID () as identifier;
        """
    }
    
    let userId: IdentifierType
    let chatId: IdentifierType
}
