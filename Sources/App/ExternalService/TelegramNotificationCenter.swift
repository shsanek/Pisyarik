import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class TelegramNotificationCenter {
    static var shared: TelegramNotificationCenter?
    
    private let token: String
    private let chatID: String
    
    init(token: String, chatID: String) {
        self.token = token
        self.chatID = chatID
    }
    
    func send(_ text: String) {
        let urlString = "https://api.telegram.org/bot\(token)/sendMessage"
        let message = Message(text: text, chat_id: chatID)
        guard
            let data = try? JSONEncoder().encode(message),
            let url = URL(string: urlString)
        else {
            return
        }
        var request = URLRequest(url: url)
        request.httpBody = data
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        URLSession(configuration: .default).dataTask(with: request) { _, _, _ in
            // log for log
        }.resume()
    }
}


extension TelegramNotificationCenter {
    struct Message: Encodable {
        let text: String
        let chat_id: String
    }
}
