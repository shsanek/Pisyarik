import Crypto
import Foundation

enum CryptoUtils {
    static func generateKey(userPublicKey: String) throws -> (uuid: String, publicKey: String, symmetricKey: String) {
        let uuid = UUID().uuidString
        if #available(macOS 11.0, *) {
            guard let salt = uuid.data(using: .utf8) else {
                throw Errors.internalError.description(
                    "Не удалось преобразовать салат(token) в дату проверь utf8"
                )
            }
            let serverPrivateKey = P521.KeyAgreement.PrivateKey()
            let userPublicKey = try Errors.internalError.handle("Ошибка криптографии") {
                try P521.KeyAgreement.PublicKey(
                    pemRepresentation: userPublicKey
                )
            }
            let serverSharedSecret = try Errors.internalError.handle("Ошибка криптографии") {
                try serverPrivateKey.sharedSecretFromKeyAgreement(with: userPublicKey)
            }
            let secretSymmetricKey = serverSharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: salt,
                sharedInfo: Data(),
                outputByteCount: 32
            )
            let symmetricKey = secretSymmetricKey.withUnsafeBytes {
                return Data(Array($0)).base64EncodedString().cleanHash
            }
            guard let symmetricKey = symmetricKey else {
                throw Errors.loginErrors.description(
                    "Не удалось собрать семетричный ключ для токена"
                )
            }
            return (
                uuid: uuid,
                publicKey: serverPrivateKey.publicKey.pemRepresentation,
                symmetricKey: String(symmetricKey.prefix(64))
            )
        } else {
            return (
                uuid: uuid,
                publicKey: "",
                symmetricKey: ""
            )
        }
    }
}
