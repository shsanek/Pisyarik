struct DBUserRaw: Decodable {
    let name: String
}

struct DBChatRaw: Decodable {
    let name: String
}

struct DBTokenRaw: Decodable {
    let token: String
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
    let identifier: IdentifierType
}

typealias IdentifierType = UInt

struct DBIdentifier: Codable {
    let identifier: IdentifierType
}
