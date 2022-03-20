import Foundation

struct ChatMakePersonalHandler: IRequestHandler {
    var name: String {
        "chat/make_personal"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) throws -> FuturePromise<ChatOutput> {
        parameters.getUser.then { me in
            dataBase.run(request: DBGetUserRequest(userId: parameters.input.userId)).only().map { (me: me, user: $0) }
        }.then { result in
            firstly { () -> FuturePromise<String> in
                let identifiers = ["\(result.user.user_id)", "\(result.me.identifier)"].sorted(by: >)
                return .value("SYS ##\(identifiers.joined(separator: "-"))##")
            }.map { name in
                dataBase.run(
                    request: DBGetChatRequest.init(
                        userId: result.me.identifier,
                        personalChatName: name
                    )
                ).then { chats -> FuturePromise<ChatOutput> in
                    if chats.count == 1 {
                        return .value(ChatOutput(chats[0], authorisationInfo: result.me))
                    } else if chats.count > 1 {
                        throw Errors.unknown.description(
                            "Тут должен был быть один обьект или 0 а пришло \(chats.count)",
                            error: nil
                        )
                    } else {
                        return try makeChat(
                            parameters: parameters,
                            dataBase: dataBase,
                            chatName: name,
                            me: result.me,
                            user: result.user
                        )
                    }
                }
            }
        }
    }
    
    private func makeChat(
        parameters: RequestParameters<Input>,
        dataBase: IDataBase,
        chatName: String,
        me: AuthorisationInfo,
        user: DBUserRaw
    ) throws -> FuturePromise<ChatOutput> {
        firstly {
            try ChatMakeHandler(type: .personal).handle(
                .init(
                    authorisationInfo: parameters.authorisationInfo,
                    updateCenter: parameters.updateCenter,
                    input: .init(
                        name: chatName
                    ),
                    time: parameters.time,
                    ws: parameters.ws
                ),
                dataBase: dataBase
            )
        }.map { (user: user, chat: $0, me: me) }.then { result in
            dataBase.run(
                request: DBAddUserInChatRequest(
                    userId: parameters.input.userId,
                    chatId: result.chat.chatId
                )
            ).get { _ in
                parameters.updateCenter.update(
                    action: NewPersonalChatAction(
                        autor: result.me.user.user_id,
                        chat: ChatOutput(
                            name: result.me.user.user_name,
                            chatId: result.chat.chatId,
                            type: ChatType.personal.rawValue,
                            message: result.chat.message,
                            lastMessageId: nil,
                            notReadCount: 0
                        ),
                        userId: result.user.user_id
                    )
                )
            }.map { _ in
                ChatOutput(
                    name: result.user.user_name,
                    chatId: result.chat.chatId,
                    type: ChatType.personal.rawValue,
                    message: result.chat.message,
                    lastMessageId: nil,
                    notReadCount: 0
                )
            }
        }
    }
}

extension ChatMakePersonalHandler {
    struct Input: Codable {
        let userId: IdentifierType
    }
}
