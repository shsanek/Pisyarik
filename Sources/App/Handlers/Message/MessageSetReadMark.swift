import PromiseKit
import Foundation

struct MessageSetReadMark: IRequestHandler {
    var name: String {
        "message/set_read"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        return parameters.getUser.then { info in
            dataBase.run(
                request: DBUpdateReadMessageRequest(
                    messageId: parameters.input.messageId,
                    chatId: parameters.input.chatId,
                    userId: info.identifier
                )
            )
        }.only.map { result in
            Output(count: result.count)
        }
    }
}

extension MessageSetReadMark {
    struct Input: Codable {
        let chatId: IdentifierType
        let messageId: IdentifierType
    }

    struct Output: Codable {
        let count: Int
    }
}
