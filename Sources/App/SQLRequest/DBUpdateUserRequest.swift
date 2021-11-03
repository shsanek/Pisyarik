struct DBUpdateUserRequest: IDBRequest {
    typealias Result = EmptyRaw

    var description: String {
        "Update user info"
    }
    var request: String {
        var changes = [(label: String, value: String)]()
        if let user_first_name = user.user_first_name {
            changes.append((label: "first_name", value: "'\(user_first_name)'"))
        }
        if let user_last_name = user.user_last_name {
            changes.append((label: "last_name", value: "'\(user_last_name)'"))
        }
        if let user_emoji = user.user_emoji {
            changes.append((label: "emoji", value: "'\(user_emoji)'"))
        }
        if let user_background_hex = user.user_background_hex {
            changes.append((label: "background_hex", value: "'\(user_background_hex)'"))
        }
        return """
            UPDATE user
            SET \(changes.map { "\($0.label) = \($0.value)" }.joined(separator: ","))
            WHERE identifier = \(user.user_id);
        """
    }

    let user: DBUserRaw
}
