struct DBPersonalNameRaw: Codable {
    let personal_user_name: String?
}

extension DBPersonalNameRaw {
    static var sqlGET: String {
        """
                personal_user.name as personal_user_name
        """
    }
}
