struct InputRequestRaw<Input: Decodable>: Decodable {
    let token: String?
    let parameters: Input
}
