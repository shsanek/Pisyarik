struct DBAddTokenForUserRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Insert token for user"
    }
    var request: String {
        "INSERT INTO token(token, user_id) VALUES ('\(token.token)', \(token.user_id)); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let token: DBTokenRaw
}
