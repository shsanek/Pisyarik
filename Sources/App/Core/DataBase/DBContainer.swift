struct DBContainer2<Content1: Decodable, Content2: Decodable> {
    let content1: Content1
    let content2: Content2
}

extension DBContainer2: Decodable {
    init(from decoder: Decoder) throws {
        self.content1 = try Content1(from: decoder)
        self.content2 = try Content2(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}

struct DBContainer3<Content1: Decodable, Content2: Decodable, Content3: Decodable>: Decodable {
    let content1: Content1
    let content2: Content2
    let content3: Content3

    init(from decoder: Decoder) throws {
        self.content1 = try Content1(from: decoder)
        self.content2 = try Content2(from: decoder)
        self.content3 = try Content3(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}

struct DBContainer4<Content1: Decodable, Content2: Decodable, Content3: Decodable, Content4: Decodable>: Decodable {
    let content1: Content1
    let content2: Content2
    let content3: Content3
    let content4: Content4

    init(from decoder: Decoder) throws {
        self.content1 = try Content1(from: decoder)
        self.content2 = try Content2(from: decoder)
        self.content3 = try Content3(from: decoder)
        self.content4 = try Content4(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}

struct DBContainer5<
    Content1: Decodable,
    Content2: Decodable,
    Content3: Decodable,
    Content4: Decodable,
    Content5: Decodable
>: Decodable {
    let content1: Content1
    let content2: Content2
    let content3: Content3
    let content4: Content4
    let content5: Content5

    init(from decoder: Decoder) throws {
        self.content1 = try Content1(from: decoder)
        self.content2 = try Content2(from: decoder)
        self.content3 = try Content3(from: decoder)
        self.content4 = try Content4(from: decoder)
        self.content5 = try Content5(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
    }
}
