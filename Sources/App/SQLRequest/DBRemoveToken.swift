struct DBRemoveToken: IDBRequest {
    typealias Result = EmptyRaw

    let description: String
    let request: String

    init(token: String) {
        self.request = "DELETE FROM token WHERE token.token = '\(token)';"
        self.description = "Remove token"
    }
}
