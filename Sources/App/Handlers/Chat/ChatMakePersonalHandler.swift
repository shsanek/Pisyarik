import PromiseKit
import Foundation

struct ChatMakePersonalHandler: IRequestHandler {
    var name: String {
        return "chat/make_personal"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        parameters.getUser.then { me in
            dataBase.run(request: DBGetUserRequest(userId: parameters.input.userId)).only.map { (me: me, user: $0) }
        }.then { result in
            ChatMakeHandler(isPersonal: true).handle(
                .init(
                    authorisationInfo: parameters.authorisationInfo,
                    input: .init(
                        name: "SYS ##\(["\(result.user.identifier)", "\(result.me.identifier)"].sorted(by: >).joined(separator: "-"))##"
                    )
                ),
                dataBase: dataBase
            ).map { (user: result.user, chat: $0) }
        }
        .then { result in
            dataBase.run(
                request: DBAddUserInChatRequest(
                    userId: parameters.input.userId,
                    chatId: result.chat.chatId
                )
            ).map { _ in
                Output(
                    chatId: result.chat.chatId,
                    user: .init(
                        name: result.user.content.name,
                        userId: result.user.identifier,
                        isSelf: false
                    )
                )
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
        let user: UsersOutput.User
    }
}

