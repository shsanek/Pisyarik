public enum DebugeNotificationCenter {
    public static func setup(token: String, chatID: String) {
        TelegramNotificationCenter.shared = .init(token: token, chatID: chatID)
    }

    public static func send(_ message: String) {
        TelegramNotificationCenter.shared?.send(message)
    }
}
