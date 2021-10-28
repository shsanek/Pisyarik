struct DBAddChatRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new chat '\(name)'"
    }
    var request: String {
        "INSERT INTO chat(name) VALUES ('\(name)'); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let name: String
}
