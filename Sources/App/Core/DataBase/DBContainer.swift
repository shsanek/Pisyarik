struct DBContainer<Content: Decodable>: Decodable {
    let identifier: IdentifierType
    let content: Content
    
    init(from decoder: Decoder) throws {
        self.identifier = try decoder.container(keyedBy: CodingKeys.self).decode(IdentifierType.self, forKey: .identifier)
        self.content = try decoder.singleValueContainer().decode(Content.self)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case identifier
    }
}
