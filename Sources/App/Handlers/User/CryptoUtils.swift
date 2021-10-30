import Crypto
import Foundation

final class CryptoUtils {
    static func generateKey(userPublicKey: String) throws -> (uuid: String, publicKey: String, symmetricKey: String) {
        let uuid = UUID().uuidString
        if #available(macOS 11.0, *) {
            guard let salt = uuid.data(using: .utf8) else {
                throw UserError.loginError
            }
            let serverPrivateKey = P521.KeyAgreement.PrivateKey()
            let userPublicKey = try P521.KeyAgreement.PublicKey(
                pemRepresentation: userPublicKey
            )
            let serverSharedSecret = try serverPrivateKey.sharedSecretFromKeyAgreement(with: userPublicKey)
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
                throw UserError.loginError
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
