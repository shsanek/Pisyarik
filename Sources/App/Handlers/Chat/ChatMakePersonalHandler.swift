import PromiseKit
import Foundation

struct ChatMakePersonalHandler: IRequestHandler {
    var name: String {
        return "chat/make_personal"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        parameters.getUser.then { me in
            dataBase.run(request: DBGetUserRequest(userId: parameters.input.userId))
            .only.map { user in
                "\(me.name) - \(user.content.name)"
            }
        }.then { name in
            ChatMakeHandler().handle(
                .init(
                    authorisationInfo: parameters.authorisationInfo,
                    input: .init(name: name)
                ),
                dataBase: dataBase
            )
        }.then { result in
            ChatAddUserHandler().handle(
                .init(
                    authorisationInfo: parameters.authorisationInfo,
                    input: .init(chatId: result.chatId, userId: parameters.input.userId)
                ),
                dataBase: dataBase
            ).map { _ in
                Output(chatId: result.chatId)
            }
        }
    }
}

extension ChatMakePersonalHandler {
    struct Input: Codable {
        let userId: IdentifierType
    }

    struct Output: Codable {
        let chatId: IdentifierType
    }
}

