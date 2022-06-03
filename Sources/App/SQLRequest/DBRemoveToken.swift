struct DBRemoveToken: IDBRequest {
    typealias Result = EmptyRaw

    let token: String

    var description: String {
        "Remove token"
    }

    func request() throws -> String {
        return "DELETE FROM token WHERE token.token = '\(try token.safe())';"
    }
}
