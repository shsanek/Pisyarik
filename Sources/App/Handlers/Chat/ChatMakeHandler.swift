import Foundation

struct ChatMakeHandler: IRequestHandler {
    var name: String {
        "chat/make"
    }

    let type: ChatType

    init(type: ChatType = .group) {
        self.type = type
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<ChatOutput> {
        parameters.onlyLogin.map { _ -> Void in
            guard parameters.input.name.count < 40 else {
                throw Errors.incorrectName.description(
                    "Проверь правильность имени пока ограничения такие (< 40)"
                )
            }
            return Void()
        }.next {
            dataBase.run(request: DBGetLightChatRequest(name: parameters.input.name))
        }.handle { result in
            guard result.count == 0 else {
                throw Errors.nameAlreadyRegistry.description(
                    "Такое имя чата уже существует (ну пока вот так)"
                )
            }
        }.next {
            dataBase.run(request: DBAddChatRequest(name: parameters.input.name, type: self.type.rawValue))
        }.only().then { chat -> FuturePromise<Output> in
            parameters.getUser.then { info in
                dataBase.run(
                    request: DBAddUserInChatRequest(
                        userId: info.identifier,
                        chatId: chat.identifier
                    )
                ).next {
                    dataBase.sendSystemMessage(chatId: chat.identifier, message: "Start chat")
                }
            }.map { message in
                ChatOutput(
                    name: parameters.input.name,
                    chatId: chat.identifier,
                    type: ChatType.group.rawValue,
                    message: message,
                    lastMessageId: nil,
                    notReadCount: 0
                )
            }
        }
    }
}

extension ChatMakeHandler {
    struct Input: Codable {
        let name: String
    }
}
