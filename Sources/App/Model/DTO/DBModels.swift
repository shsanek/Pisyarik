struct DBCountRaw: Codable {
    let count: Int
}

struct DBIdentifier: Codable {
    let identifier: IdentifierType
}

typealias IdentifierType = UInt
