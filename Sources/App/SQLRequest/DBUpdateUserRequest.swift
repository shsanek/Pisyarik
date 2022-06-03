struct DBUpdateUserRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Update user info"
    }
    func request() throws -> String {
        var changes = [(label: String, value: String)]()
        if let user_first_name = user.user_first_name {
            changes.append((label: "first_name", value: "'\(try user_first_name.safe())'"))
        }
        if let user_last_name = user.user_last_name {
            changes.append((label: "last_name", value: "'\(try user_last_name.safe())'"))
        }
        if let user_emoji = user.user_emoji {
            changes.append((label: "emoji", value: "'\(try user_emoji.safe())'"))
        }
        if let user_background_hex = user.user_background_hex {
            changes.append((label: "background_hex", value: "'\(try user_background_hex.safe())'"))
        }
        return """
            UPDATE user
            SET \(changes.map { "\($0.label) = \($0.value)" }.joined(separator: ","))
            WHERE identifier = \(user.user_id);
        """
    }

    let user: DBUserRaw
}
