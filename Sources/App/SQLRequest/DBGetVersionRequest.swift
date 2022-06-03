struct DBGetVersionRequest: IDBRequest {
    typealias Result = DBVersionDTO

    let description = "Get current DB version"
    func request() throws -> String {
        "SELECT * FROM version;"
    }
}
