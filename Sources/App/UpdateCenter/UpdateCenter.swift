import PromiseKit

final class UpdateCenter {
    private let dataBase: IDataBase
    private let lock: Lock = Lock()
    private var listeners = [IdentifierType: Listener]()
    

    init(dataBase: IDataBase) {
        self.dataBase = dataBase
    }
    
    func addListener(id: IdentifierType) -> Promise<[NotificationOutputContainer]> {
        lock.lockWriting()
        defer {
            lock.unlock()
        }
        let listener = listeners[id] ?? create(id: id)
        listener.active = true
        return listener.promise
    }

    func update(action: UpdateAction) {
        switch action {
        case .newMessage(let message):
            self.newMessage(message)
        case .addInNewChat(let chat, let userId):
            self.addInNewChat(chat, userId: userId)
        case .newPersonalChat(let chat, let userId):
            self.newPersonalChat(chat, userId: userId)
        }
    }
    
    private func create(id: IdentifierType) -> Listener {
        let listener = Listener() { [weak self] active in
            if active {
                _ = self?.create(id: id)
            }
        }
        listeners[id] = listener
        return listener
    }
}

private extension UpdateCenter {
    func newMessage(_ message: MessagesOutput.Message) {
        dataBase.run(request: DBGetUserRequest(chatId: message.chatId)).done { result in
            self.lock.lockReading()
            defer {
                self.lock.unlock()
            }
            for user in result {
                if user.identifier != message.user.userId {
                    self.listeners[user.identifier]?.append(.init(NotificationOutput(type: .newMessage, content: message)))
                }
            }
        }.catch { _ in }
    }
    
    func newPersonalChat(_ output: ChatMakePersonalHandler.Output, userId: IdentifierType) {
        self.listeners[userId]?.append(.init(NotificationOutput(type: .addedInNewChat, content: output)))

    }

    func addInNewChat(_ chat: ChatsOutput.Chat, userId: IdentifierType) {
        self.listeners[userId]?.append(.init(NotificationOutput(type: .newPersonalChat, content: chat)))
    }
}
