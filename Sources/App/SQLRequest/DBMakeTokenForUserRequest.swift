struct DBMakeTokenForUserRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Insert token for user"
    }
    var request: String {
        "INSERT INTO token(token, user_id) VALUES ('\(token.token)', \(token.user_id));"
    }
    
    let token: DBTokenRaw
}
