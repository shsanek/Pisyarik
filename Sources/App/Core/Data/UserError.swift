struct UserError: Codable {
    let name: String
    let description: String
    let info: String?
}

extension UserError {
    static var defaultError: String {
        """
        {
            "status": "error",
            "errors": [{
                "name": "unknown error",
                "description": "unexpected behavior"
            }]
        }
        """
    }

    static var notFoundError: String {
        """
        {
            "status": "error",
            "errors": [{
                "name": "Method not found",
                "description": "Method not found"
            }]
        }
        """
    }
}

extension UserError: Error, UserErrorHandable{
    func generateError() -> UserError {
        return self
    }
}

extension UserError {
    init(_ error: Error) {
        self.name = "unknown error"
        self.info = "\(error)"
        self.description = error.localizedDescription
    }
}

protocol UserErrorHandable {
    func generateError() -> UserError
}

extension Error {
    func makeUserError() -> UserError {
        (self as? UserErrorHandable)?.generateError() ?? UserError(self)
    }
}

extension UserError {
    static var alreadyLogin: UserError {
        return UserError(name: "User already login", description: "User already login", info: nil)
    }
    
    static var incorrectToken: UserError {
        return UserError(name: "Incorrect token", description: "Incorrect token", info: nil)
    }
    
    static var accessError: UserError {
        return UserError(name: "Access error", description: "Access error", info: nil)
    }
}

extension UserError {
    static var incorrectName: UserError {
        return UserError(name: "Incorrect name", description: "<40", info: nil)
    }
    
    static var nameAlreadyRegistry: UserError {
        return UserError(name: "Name already registry", description: "<40", info: nil)
    }
}
