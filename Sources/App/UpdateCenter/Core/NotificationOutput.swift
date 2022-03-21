enum NotificationOutput: Codable {
    case newChat(chat: ChatOutput)
    case newMessage(message: MessageOutput)
}
