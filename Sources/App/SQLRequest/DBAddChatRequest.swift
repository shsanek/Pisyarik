struct DBAddChatRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new chat '\(name)'"
    }
    var request: String {
        "INSERT INTO chat(name, is_personal) VALUES ('\(name)', \(isPersonal)); SELECT LAST_INSERT_ID () as identifier;"
    }
    
    let name: String
    let isPersonal: Int
}
