import PromiseKit
import Foundation

struct MessageGetFromChat: IRequestHandler  {
    var name: String {
        "message/get_from_chat"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        Promise.value(parameters).map { _ -> Void in
            if parameters.input.limit > 100 {
                throw NSError(domain: "max limit 100", code: 2, userInfo: nil)
            }
            return Void()
        }
        .then { _ in parameters.getUser }
        .then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.map { result -> Void in
            if result.first?.count ?? 0 == 0 {
                throw UserError.accessError
            }
            return Void()
        }.then { _ in
            dataBase.run(
                request: DBGetMessage(
                    limit: max(100, parameters.input.limit),
                    chatId: parameters.input.chatId,
                    lastMessage: parameters.input.lastMessageId
                )
            )
        }.map {
            Output($0)
        }
    }
}

extension MessageGetFromChat {
    struct Input: Codable {
        let chatId: IdentifierType
        let limit: Int
        let lastMessageId: IdentifierType?
    }
    struct Output: Codable {
        struct Message: Codable {
            let user: UsersOutput.User
            let date: UInt
            let body: String
            let type: String
            let identifier: IdentifierType
            let chatId: IdentifierType
        }
        let messages: [Message]
    }
}

extension MessageGetFromChat.Output {
    init(_ raw: [DBContainer<DBFullMessageRaw>]) {
        self.messages = raw.map { raw in
            return .init(
                user: .init(
                    name: raw.content.author_name,
                    identifier: raw.content.author_id
                ),
                date: raw.content.date,
                body: raw.content.body,
                type: raw.content.type,
                identifier: raw.identifier,
                chatId: raw.content.chat_id
            )
        }
    }
}
