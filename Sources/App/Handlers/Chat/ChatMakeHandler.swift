import PromiseKit
import Foundation

struct ChatMakeHandler: IRequestHandler {
    var name: String {
        return "chat/make"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        parameters.onlyLogin.map { result -> Void in
            guard parameters.input.name.count < 40 else {
                throw UserError.incorrectName
            }
            return Void()
        }.then { _ in
            dataBase.run(request: DBGetChatRequest(name: parameters.input.name))
        }.map { result -> Void in
            guard result.count == 0 else {
                throw UserError.nameAlreadyRegistry
            }
            return Void()
        }.then { _ in
            dataBase.run(request: DBAddChatRequest(name: parameters.input.name))
        }.only.then { chat -> Promise<Output> in
            parameters.getUser.then { info in
                dataBase.run(
                    request: DBAddUserInChatRequest(
                        userId: info.identifier,
                        chatId: chat.identifier
                    )
                ).then { _ in
                    dataBase.run(
                        request: DBAddMessageRequest(
                            message: DBMessageRaw(
                                author_id: info.identifier,
                                chat_id: chat.identifier,
                                date: UInt(Date.timeIntervalSinceReferenceDate),
                                body: "Start chat",
                                type: "SYSTEM_TEXT"
                            )
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
