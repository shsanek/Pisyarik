struct UserOutput: Codable {
    let name: String
    let userId: IdentifierType
    let isSelf: Bool
}

extension UserOutput {
    init(_ user: DBUserRaw, authorisationInfo: AuthorisationInfo?) {
        self.name = user.user_name
        self.isSelf = user.user_id == authorisationInfo?.identifier
        self.userId = user.user_id
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
