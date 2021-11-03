struct DBUserRaw: Decodable {
    let user_id: IdentifierType
    let user_name: String
    let user_security_hash: String?
    let user_first_name: String?
    let user_last_name: String?
    let user_background_hex: String?
    let user_emoji: String?
}

extension DBUserRaw {
    static func sqlGET(_ hasSecurity: Bool = false) -> String {
        var sql = """
            user.identifier as user_id,
            user.name as user_name,
            user.first_name as user_first_name,
            user.last_name as user_last_name,
            user.background_hex as user_background_hex,
            user.emoji as user_emoji
        """
        if hasSecurity {
            sql += ", user.security_hash as user_security_hash"
        }
        return sql
    }
}

extension DBUserRaw {
    static var systemUserId: IdentifierType {
        1
    }
}
