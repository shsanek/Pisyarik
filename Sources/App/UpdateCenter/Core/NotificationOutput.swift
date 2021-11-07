struct NotificationOutput<Content: Encodable>: Encodable {
    let type: NotificationType
    let content: Content
}

struct NotificationOutputContainer: Encodable {
    private let encodeHandler: (_ encoder: Encoder) throws -> Void

    init<Content: Encodable>(_ notification: NotificationOutput<Content>) {
        self.encodeHandler = notification.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeHandler(encoder)
    }
}
