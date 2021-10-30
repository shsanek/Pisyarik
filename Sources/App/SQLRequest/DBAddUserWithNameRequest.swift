struct DBAddUserWithNameRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Make user with user"
    }
    var request: String {
        "INSERT INTO user(name, security_hash) VALUES ('\(name)','\(securityHash)'); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let name: String
    let securityHash: String
}
