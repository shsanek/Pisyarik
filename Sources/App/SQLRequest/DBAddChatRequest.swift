struct DBAddChatRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Add new chat '\(name)'"
    }
    var request: String {
        "INSERT INTO chat(name) VALUES ('\(name)');"
    }
    
    let name: String
}
