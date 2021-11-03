struct DBUserRaw: Decodable {
    let user_id: IdentifierType
    let user_name: String
    let user_security_hash: String?
}

extension DBUserRaw {
    static func sqlGET(_ hasSecurity: Bool = false) -> String {
        var sql = "user.identifier as user_id, user.name as user_name"
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
