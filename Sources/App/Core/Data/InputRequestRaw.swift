struct InputRequestRaw<Input: Decodable>: Decodable {
    let time: UInt
    let reuestId: String?
    let authorisation: Authorisation?
    let content: Input
}

struct Authorisation: Codable {
    let token: String
    let secretKey: String
}

struct InputRequestRawMetaInfo: Decodable {
    let method: String
    let reuestId: String
}
