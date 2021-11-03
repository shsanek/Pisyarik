struct InputRequestRaw<Input: Decodable>: Decodable {
    let time: UInt
    let authorisation: Authorisation?
    let content: Input
}

struct Authorisation: Codable {
    let token: String
    let secretKey: String
}
