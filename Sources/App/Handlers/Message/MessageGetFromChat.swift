import Foundation

struct MessageGetFromChat: IRequestHandler {
    var name: String {
        "message/get_from_chat"
    }

    func handle(
        _ parameters: RequestParameters<Input>,
        dataBase: IDataBase
    ) throws -> FuturePromise<MessageListOutput> {
        FuturePromise.value(parameters).map { _ -> Void in
            if parameters.input.limit > 100 {
                throw Errors.internalError.description(
                    "Превышен лимит в 100"
                )
            }
            return Void()
        }
        .next { parameters.getUser }
        .then { info in
            dataBase.run(
                request: DBGetContainsUserInChat(
                    userId: info.identifier,
                    chatId: parameters.input.chatId
                )
            )
        }.handle { result in
            if result.first?.count ?? 0 == 0 {
                throw Errors.accessError.description(
                    "Пользователя нет в этом чате"
                )
            }
        }.next {
            dataBase.run(
                request: DBGetMessage(
                    limit: max(100, parameters.input.limit),
                    chatId: parameters.input.chatId,
                    lastMessage: parameters.input.lastMessageId,
                    reverse: parameters.input.reverse ?? false
                )
            )
        }.map {
            MessageListOutput($0, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension MessageGetFromChat {
    struct Input: Codable {
        let chatId: IdentifierType
        let limit: Int
        let lastMessageId: IdentifierType?
        let reverse: Bool?
    }
}
