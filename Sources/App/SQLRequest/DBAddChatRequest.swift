struct DBAddChatRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Add new chat '\(name)'"
    }

    func request() throws -> String {
        """
        INSERT INTO chat(name, type)
        VALUES ('\(try name.safe())', '\(try type.safe())');
        SELECT LAST_INSERT_ID () as identifier;
        """
    }

    let name: String
    let type: String
}
