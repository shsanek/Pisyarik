import PromiseKit
import Foundation

struct ChatMakePersonalHandler: IRequestHandler {
    var name: String {
        "chat/make_personal"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> Promise<Output> {
        parameters.getUser.then { me in
            dataBase.run(request: DBGetUserRequest(userId: parameters.input.userId)).only.map { (me: me, user: $0) }
        }.then { result in
            firstly { () -> Promise<String> in
                let identifiers = ["\(result.user.user_id)", "\(result.me.identifier)"].sorted(by: >)
                return .value("SYS ##\(identifiers.joined(separator: "-"))##")
            }.then { chatName in
                try ChatMakeHandler(isPersonal: true).handle(
                    .init(
                        authorisationInfo: parameters.authorisationInfo,
                        updateCenter: parameters.updateCenter,
                        input: .init(
                            name: chatName
                        ),
                        time: parameters.time
                    ),
                    dataBase: dataBase
                )
            }.map { (user: result.user, chat: $0, me: result.me) }
        }.then { result in
            dataBase.run(
                request: DBAddUserInChatRequest(
                    userId: parameters.input.userId,
                    chatId: result.chat.chatId
                )
            ).get { _ in
                parameters.updateCenter.update(
                    action: .newPersonalChat(
                        .init(
                            chatId: result.chat.chatId,
                            user: .init(
                                name: result.me.name,
                                userId: result.me.identifier,
                                isSelf: false
                            )
                        ),
                        userId: result.user.user_id
                    )
                )
            }.map { _ in
                Output(
                    chatId: result.chat.chatId,
                    user: .init(
                        name: result.user.user_name,
                        userId: result.user.user_id,
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
        let user: UserOutput
    }
}
