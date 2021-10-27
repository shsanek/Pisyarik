struct DBUpdateVersionRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Update BD version value to '\(version)'"
    }
    var request: String {
        "UPDATE version SET version = \(version) WHERE identifier = 0;"
    }
    
    let version: Int
}
