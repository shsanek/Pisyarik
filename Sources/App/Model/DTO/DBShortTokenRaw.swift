struct DBShortTokenRaw: Codable {
    let token_token: String
    let token_user_id: IdentifierType
    let token_apns_token: String?
}

extension DBShortTokenRaw {
    static var sqlGET: String {
        """
        token.token as token_token,
        token.user_id as token_user_id,
        token.apns_token as token_apns_token
        """
    }

    static var sqlNotApnsGET: String {
        """
        token.token as token_token,
        token.user_id as token_user_id
        """
    }
}
