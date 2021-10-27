struct DBMakeUserWithNameRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Make user with user"
    }
    var request: String {
        "INSERT INTO user(name) VALUES ('\(name)');"
    }
    
    let name: String
}
