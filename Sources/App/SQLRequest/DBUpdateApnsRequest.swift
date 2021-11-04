struct DBUpdateApnsRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "added apns"
    }

    var request: String {
        "UPDATE token SET apns_token = '\(apnsToken)' WHERE token = '\(token)';"
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
