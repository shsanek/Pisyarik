import PromiseKit
import Vapor
import APNS

final class UpdateCenter {
    private let dataBase: IDataBase
    private let lock = Lock()
    private var listeners: [IdentifierType: Listener] = [:]
    private let app: Application

    init(dataBase: IDataBase, app: Application) {
        self.dataBase = dataBase
        self.app = app
    }

    func addListener(id: IdentifierType) -> FuturePromise<[NotificationOutputContainer]> {
        lock.lockWriting()
        defer {
            lock.unlock()
        }
        let listener = listeners[id] ?? make(id: id)
        listener.active = true
        let promise = listener.lazy.promise()
        return FuturePromise { eventLoop in
            return promise.toFeature(eventLoop)
        }
    }

    func update(action: UpdateAction) {
        self.lock.lockReading()
        defer {
            self.lock.unlock()
        }
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
            guard let self = self else {
                return
            }
            self.lock.lockWriting()
            defer {
                self.lock.unlock()
            }
            if active {
                _ = self.make(id: id)
            } else {
                self.listeners[id] = nil
            }
        }
        listeners[id] = listener
        return listener
    }
}

private extension UpdateCenter {
    func newMessage(_ message: MessageOutput) {
        try? dataBase.run(request: DBGetUserRequest(chatId: message.chatId)).handle { result in
            self.lock.lockReading()
            defer {
                self.lock.unlock()
            }
            var pushUsers: [IdentifierType] = []
            for user in result where user.user_id != message.user.userId {
                if let listener = self.listeners[user.user_id] {
                    listener.append(
                        .init(
                            NotificationOutput(
                                type: .newMessage,
                                content: message
                            )
                        )
                    )
                } else {
                    pushUsers.append(user.user_id)
                }
            }
            self.send(userIds: pushUsers, title: "\(message.user.name)", text: "\(message.content.prefix(100))")
        }.make(app.eventLoopGroup.next()).whenComplete { _ in }
    }

    func newPersonalChat(_ output: ChatMakePersonalHandler.Output, userId: IdentifierType) {
        if let listener = self.listeners[userId] {
            listener.append(.init(NotificationOutput(type: .newPersonalChat, content: output)))
        } else {
            self.send(userIds: [userId], title: "\(output.user.name)", text: "Начал диалог")
        }
    }

    func addInNewChat(_ chat: ChatOutput, userId: IdentifierType) {
        if let listener = self.listeners[userId] {
            listener.append(.init(NotificationOutput(type: .addedInNewChat, content: chat)))
        } else {
            self.send(userIds: [userId], title: "\(chat.name)", text: "Добро пожаловать в чат")
        }
    }
}

extension UpdateCenter {
    func send(userIds: [IdentifierType], title: String, text: String) {
        for id in userIds {
            try? firstly {
                dataBase.run(request: DBApnsTokenRequest(userId: id))
            }.handle { tokens in
                for token in tokens {
                    if let id = token.identifier {
                        self.app.apns.send(
                            .init(title: title, subtitle: text),
                            to: id
                        ).whenComplete { result in
                            print(result)
                            }
                    }
                }
            }.make(app.eventLoopGroup.next()).whenComplete { _ in }
        }
    }
}
