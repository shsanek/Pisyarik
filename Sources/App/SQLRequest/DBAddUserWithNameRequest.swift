struct DBAddUserWithNameRequest: IDBRequest {
    typealias Result = DBIdentifier

    var description: String {
        "Make user with user"
    }
    func request() throws -> String {
        """
        INSERT INTO user(name, security_hash)
        VALUES ('\(try name.safe())','\(try securityHash.safe())');
        SELECT LAST_INSERT_ID () as identifier;
        """
    }

    let name: String
    let securityHash: String
}
