struct DBAddTokenForUserRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Insert token for user"
    }
    var request: String {
        """
        INSERT INTO token(token, user_id, secret_key)
        VALUES ('\(token.token_token)', \(token.token_user_id), '\(token.token_secret_key)');
        SELECT LAST_INSERT_ID () as identifier;
        """
    }

    let token: DBTokenRaw
}
