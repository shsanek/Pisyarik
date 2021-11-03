import PromiseKit
import Foundation

struct ChatMakeHandler: IRequestHandler {
    var name: String {
        "chat/make"
    }

    let isPersonal: Bool

    init(isPersonal: Bool = false) {
        self.isPersonal = isPersonal
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        parameters.onlyLogin.map { _ -> Void in
            guard parameters.input.name.count < 40 else {
                throw Errors.incorrectName.description(
                    "Проверь правильность имени пока ограничения такие (< 40)"
                )
            }
            return Void()
        }.then { _ in
            dataBase.run(request: DBGetLightChatRequest(name: parameters.input.name))
        }.handler { result in
            guard result.count == 0 else {
                throw Errors.nameAlreadyRegistry.description(
                    "Такое имя чата уже существует (ну пока вот так)"
                )
            }
        }.then { _ in
            dataBase.run(request: DBAddChatRequest(name: parameters.input.name, type: ChatType.group.rawValue))
        }.only.then { chat -> Promise<Output> in
            parameters.getUser.then { info in
                dataBase.sendSystemMessage(chatId: chat.identifier, message: "Start chat").then { _ in
                    dataBase.run(
                        request: DBAddUserInChatRequest(
                            userId: info.identifier,
                            chatId: chat.identifier
                        )
                    )
                }
            }.map { _ in
                Output(chatId: chat.identifier)
            }
        }
    }
}

extension ChatMakeHandler {
    struct Input: Codable {
        let name: String
    }

    struct Output: Codable {
        let chatId: IdentifierType
    }
}
