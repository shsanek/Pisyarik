struct DBAddUserWithNameRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Make user with user"
    }
    var request: String {
        "INSERT INTO user(name) VALUES ('\(name)'); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let name: String
}
