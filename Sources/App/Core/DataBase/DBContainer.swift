struct DBContainer<Content: Decodable>: Decodable {
    let identifier: IdentifierType
    let content: Content

    init(from decoder: Decoder) throws {
        self.identifier = try decoder.container(keyedBy: CodingKeys.self)
            .decode(IdentifierType.self, forKey: .identifier)

        self.content = try decoder.singleValueContainer().decode(Content.self)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}

struct DBContainer2<Content1: Decodable, Content2: Decodable>: Decodable {
    let identifier: IdentifierType
    let content1: Content1
    let content2: Content2?

    init(from decoder: Decoder) throws {
        self.identifier = try decoder.container(keyedBy: CodingKeys.self)
            .decode(IdentifierType.self, forKey: .identifier)

        self.content1 = try decoder.singleValueContainer().decode(Content1.self)
        self.content2 = try? decoder.singleValueContainer().decode(Content2.self)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}
