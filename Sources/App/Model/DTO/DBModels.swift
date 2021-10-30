struct DBUserRaw: Decodable {
    let name: String
    let security_hash: String?
    let secret_key: String?
}

struct DBChatRaw: Decodable {
    let name: String
    let is_personal: Int
    let not_read_message_count: Int?
    let last_read_message_id: IdentifierType?
}

struct DBTokenRaw: Codable {
    let token: String
    let secret_key: String
    let user_id: IdentifierType
}

struct DBCountRaw: Codable {
    let count: Int
}

struct DBMessageRaw: Codable {
    let author_id: IdentifierType
    let chat_id: IdentifierType
    let date: UInt
    let body: String
    let type: String
}

struct DBFullMessageRaw: Codable {
    let chat_id: IdentifierType
    let author_id: IdentifierType
    let author_name: String
    let body: String
    let date: UInt
    let type: String
    let message_id: IdentifierType
}

typealias IdentifierType = UInt

struct DBIdentifier: Codable {
    let identifier: IdentifierType
}
