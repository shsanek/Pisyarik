struct DBAddTokenForUserRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Insert token for user"
    }
    func request() throws -> String {
        """
        INSERT INTO token(token, user_id, secret_key)
        VALUES ('\(try token.token_token.safe())', \(token.token_user_id), '\(try token.token_secret_key.safe())');
        SELECT LAST_INSERT_ID () as identifier;
        """
    }

    let token: DBTokenRaw
}
