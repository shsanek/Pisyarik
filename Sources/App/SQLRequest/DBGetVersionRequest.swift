struct DBGetVersionRequest: IDBRequest {
    typealias Result = DBVersionDTO

    let description = "Get current DB version"
    let request = "SELECT * FROM version;"
}
