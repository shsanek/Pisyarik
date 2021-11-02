import Crypto

extension String {
    func hash(with time: UInt) -> String? {
        guard let data = (self + "\(time)").data(using: .utf8) else {
            return nil
        }
        let hash = SHA512.hash(data: data).map({ String(format: "%02x", UInt8($0)) }).joined()
        return hash
    }

    var cleanHash: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let hash = SHA512.hash(data: data).map({ String(format: "%02x", UInt8($0)) }).joined()
        return hash
    }
}
