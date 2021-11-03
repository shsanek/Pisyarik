struct DBCountRaw: Codable {
    let count: Int
}

struct DBIdentifier: Codable {
    let identifier: IdentifierType
}

typealias IdentifierType = UInt

struct DBTokenRaw: Codable {
    let token_token: String
    let token_secret_key: String
    let token_user_id: IdentifierType
    let token_apns_token: String?
}

extension DBTokenRaw {
    static var sqlGET: String {
        """
        token.token as token_token,
        secret_key as token_secret_key,
        user_id as token_user_id,
        apns_token as token_apns_token
        """
    }
}
