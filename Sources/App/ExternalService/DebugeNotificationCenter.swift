public enum DebugeNotificationCenter {
    public static func send(_ message: String) {
        TelegramNotificationCenter.shared.send(message)
    }
}
