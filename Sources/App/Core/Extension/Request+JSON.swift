import Vapor

extension ByteBuffer {
    func json<Object: Decodable>(type: Object.Type) throws -> Object {
        var bf = self
        let optionRaw = try Errors.internalError.handle("Чет с json проверь параметры") {
            try bf.readJSONDecodable(
                Object.self,
                length: bf.readableBytes
            )
        }
        guard let raw = optionRaw else {
            throw Errors.internalError.description("JSON nil оч странное поведение пни сервериста")
        }
        return raw
    }
}
