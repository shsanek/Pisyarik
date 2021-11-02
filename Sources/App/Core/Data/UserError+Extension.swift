import Foundation

extension UserError {
    static var defaultError: String {
        """
        {
            "status": "error",
            "errors": [{
                "code": "\(Errors.unknown.rawValue)",
                "developerInfo": {
                    "description": "Эту ошибку я вывожу если ошибка произошла в не стека и никакой инфы нет",
                    "error": ""
                }
            }]
        }
        """
    }

    static var notFoundError: String {
        """
                {
                    "status": "error",
                    "errors": [{
                        "code": "\(Errors.methodNotFound.rawValue)",
                        "developerInfo": {
                            "description": "Для данного метода нет обработчиков",
                            "error": ""
                        }
                    }]
                }
        """
    }
}

extension UserError: Error, UserErrorHandable {
    func generateError() -> UserError {
        return self
    }
}

extension UserError {
    init(_ error: Error) {
        if let userError = error as? UserError {
            self = userError
        } else {
            self.code = Errors.unknown.rawValue
            self.developerInfo = ErrorDeveloperInfo(
                description: "swift кинул ошибку смотри error другой инфы у меня для тебя нет",
                error: "\(error)",
                position: nil
            )
        }
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

extension Errors {
    func description(_ description: String, error: Error? = nil, file: String = #file, line: Int = #line) -> UserError {
        UserError(
            code: self.rawValue,
            developerInfo: ErrorDeveloperInfo(
                description: description,
                error: error.flatMap { "\($0)" },
                position: .init(file: file, line: line)
            )
        )
    }
}

extension Errors {
    func handle<Result>(
        _ description: String,
        file: String = #file,
        line: Int = #line,
        _ block: () throws -> Result
    ) throws -> Result {
        do {
            return try block()
        } catch {
            if let error = error as? UserError {
                throw error
            }
            throw UserError(
                code: self.rawValue,
                developerInfo: ErrorDeveloperInfo(
                    description: description,
                    error: "\(error)",
                    position: .init(file: file, line: line)
                )
            )
        }
    }

    func handle(_ description: String, file: String = #file, line: Int = #line, _ block: () throws -> Void) throws {
        do {
            try block()
        } catch {
            throw UserError(
                code: self.rawValue,
                developerInfo: ErrorDeveloperInfo(
                    description: description,
                    error: "\(error)",
                    position: .init(file: file, line: line)
                )
            )
        }
    }
}
