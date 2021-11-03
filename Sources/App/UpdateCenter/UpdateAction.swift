enum UpdateAction {
    case newMessage(_ message: MessageOutput)
    case newPersonalChat(_ output: ChatMakePersonalHandler.Output, userId: IdentifierType)
    case addInNewChat(_ chat: ChatOutput, userId: IdentifierType)
}

enum NotificationOutputType: String, Encodable {
    case newMessage
    case newPersonalChat
    case addedInNewChat
}

struct NotificationOutput<Content: Encodable>: Encodable {
    let type: NotificationOutputType
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
