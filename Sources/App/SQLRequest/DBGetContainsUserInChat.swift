struct DBGetContainsUserInChat: IDBRequest {
    typealias Result = DBCountRaw

    var description: String {
        "Get contains user in chat"
    }
    func request() throws -> String {
        """
        SELECT COUNT(*) as count FROM chat_user
        WHERE user_id = \(userId) AND chat_id = \(chatId);
        """
    }

    let userId: IdentifierType
    let chatId: IdentifierType
}
