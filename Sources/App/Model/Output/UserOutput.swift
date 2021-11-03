struct UserOutput: Codable {
    let name: String
    let userId: IdentifierType
    let isSelf: Bool
    let hex: String?
    let emoji: String?
    let firstName: String?
    let lastName: String?
}

extension UserOutput {
    init(_ user: DBUserRaw, authorisationInfo: AuthorisationInfo?) {
        self.name = user.user_name
        self.isSelf = user.user_id == authorisationInfo?.identifier
        self.userId = user.user_id
        self.firstName = user.user_first_name
        self.emoji = user.user_emoji
        self.hex = user.user_background_hex
        self.lastName = user.user_last_name
    }
}

struct UserListOutput: Codable {
    let users: [UserOutput]
}

extension UserListOutput {
    init(
        _ raws: [DBUserRaw],
        authorisationInfo: AuthorisationInfo?
    ) {
        self.users = raws.map {
            UserOutput($0, authorisationInfo: authorisationInfo)
        }
    }
}
