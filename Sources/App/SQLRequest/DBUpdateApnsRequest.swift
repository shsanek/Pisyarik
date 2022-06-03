struct DBUpdateApnsRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "added apns"
    }

    func request() throws -> String {
        "UPDATE token SET apns_token = '\(try apnsToken.safe())' WHERE token = '\(try token.safe())';"
    }

    private let apnsToken: String
    private let token: String

    init(
        apnsToken: String,
        token: String
    ) {
        self.apnsToken = apnsToken
        self.token = token
    }
}
