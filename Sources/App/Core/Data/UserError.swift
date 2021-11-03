import Foundation

struct UserError: Codable {
    var code: String
    let developerInfo: ErrorDeveloperInfo?
}

struct ErrorDeveloperInfo: Codable {
    init(
        description: String,
        error: String?,
        position: ErrorDeveloperInfo.Position?
    ) {
        self.description = description
        self.error = error
        self.position = position.flatMap({ position in
            Position(
                file: position.file.components(separatedBy: "/").last ?? "",
                line: position.line
            )
        })
    }

    let description: String
    let error: String?
    let position: Position?

    struct Position: Codable {
        let file: String
        let line: Int
    }
}

enum Errors: String {
    case unknown
    case methodNotFound

    case alreadyLogin
    case incorrectToken
    case accessError

    case incorrectName
    case nameAlreadyRegistry

    case userAlreadyInChat
    case loginErrors

    case internalError
}
