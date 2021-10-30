struct InputRequestRaw<Input: Decodable>: Decodable {
    let time: UInt
    let authorisation: Authorisation?
    let parameters: Input
}

struct Authorisation: Codable {
    let token: String
    let secretKey: String
}
