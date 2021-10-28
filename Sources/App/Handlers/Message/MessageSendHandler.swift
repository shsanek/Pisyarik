import PromiseKit
import Foundation

struct MessageSendHandler: IRequestHandler {
    var name: String {
        "message/send"
    }
    
    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        return parameters.getUser.then { info in
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
            parameters.getUser.then { info in
                dataBase.run(
                    request: DBAddMessageRequest(
                        message: DBMessageRaw(
                            author_id: info.identifier,
                            chat_id: parameters.input.chatId,
                            date: UInt(Date.timeIntervalSinceReferenceDate),
                            body: parameters.input.content,
                            type: parameters.input.type
                        )
                    )
                )
            }
        }.only.map { result in
            Output(messageId: result.identifier)
        }
    }
}

extension MessageSendHandler {
    struct Input: Codable {
        let chatId: IdentifierType
        let type: String
        let content: String
    }
    struct Output: Codable {
        let messageId: IdentifierType
    }
}
