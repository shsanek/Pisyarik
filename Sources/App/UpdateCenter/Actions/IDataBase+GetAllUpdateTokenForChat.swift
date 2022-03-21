extension IDataBase {
    func getAllUpdateTokenForChat(_ chatId: IdentifierType, autor: AuthorisationInfo?) -> FuturePromise<[InformationUpdater.Token]> {
        run(request: DBGetTokenRequest(chatId: chatId)).map { result in
            result.compactMap { raw ->  InformationUpdater.Token? in
                if raw.token_token == autor?.token {
                    return nil
                }
                return .init(
                    userId: raw.token_user_id,
                    token: raw.token_token,
                    apns: (raw.token_user_id == autor?.identifier ? nil : raw.token_apns_token)
                )
            }
        }
    }
}
