import Foundation

struct ChatGetUsersHandler: IRequestHandler {
    var name: String {
        "chat/get_users"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<UserListOutput> {
        parameters.getUser.then { info in
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
            dataBase.run(request: DBGetUserRequest(chatId: parameters.input.chatId))
        }.map { result in
            UserListOutput(result, authorisationInfo: parameters.authorisationInfo)
        }
    }
}

extension ChatGetUsersHandler {
    struct Input: Codable {
        let chatId: IdentifierType
    }
}
