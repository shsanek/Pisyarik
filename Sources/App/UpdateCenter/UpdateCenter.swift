import PromiseKit

final class UpdateCenter {
    private let dataBase: IDataBase
    private let lock = Lock()
    private var listeners: [IdentifierType: Listener] = [:]

    init(dataBase: IDataBase) {
        self.dataBase = dataBase
    }

    func addListener(id: IdentifierType) -> Promise<[NotificationOutputContainer]> {
        lock.lockWriting()
        defer {
            lock.unlock()
        }
        var listener = listeners[id] ?? make(id: id)
        if listener.active {
            listener = make(id: id)
        }
        listener.active = true
        return listener.promise
    }

    func update(action: UpdateAction) {
        switch action {
        case let .newMessage(message):
            self.newMessage(message)
        case let .addInNewChat(chat, userId):
            self.addInNewChat(chat, userId: userId)
        case let .newPersonalChat(chat, userId):
            self.newPersonalChat(chat, userId: userId)
        }
    }

    private func make(id: IdentifierType) -> Listener {
        let listener = Listener { [weak self] active in
            if active {
                _ = self?.make(id: id)
            }
        }
        listeners[id] = listener
        return listener
    }
}

private extension UpdateCenter {
    func newMessage(_ message: MessageOutput) {
        dataBase.run(request: DBGetUserRequest(chatId: message.chatId)).done { result in
            self.lock.lockReading()
            defer {
                self.lock.unlock()
            }
            for user in result where user.user_id != message.user.userId {
                self.listeners[user.user_id]?.append(
                    .init(
                        NotificationOutput(
                            type: .newMessage,
                            content: message
                        )
                    )
                )
            }
        }.catch { _ in }
    }

    func newPersonalChat(_ output: ChatMakePersonalHandler.Output, userId: IdentifierType) {
        self.listeners[userId]?.append(.init(NotificationOutput(type: .newPersonalChat, content: output)))

    }

    func addInNewChat(_ chat: ChatOutput, userId: IdentifierType) {
        self.listeners[userId]?.append(.init(NotificationOutput(type: .addedInNewChat, content: chat)))
    }
}
