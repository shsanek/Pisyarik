struct OutputRequestRaw<Output: Encodable>: Encodable {
    let state: State
    let method: String
    let requestId: String?
    let content: Output?
    let errors: [UserError]?
}

extension OutputRequestRaw {
    static func ok(_ content: Output, requestId: String?, method: String) -> Self {
        OutputRequestRaw(state: .ok, method: method, requestId: requestId, content: content, errors: nil)
    }

    static func errors(_ errors: [Error], requestId: String?, method: String) -> Self {
        OutputRequestRaw(
            state: .error,
            method: method,
            requestId: requestId,
            content: nil,
            errors: errors.map { $0.makeUserError() }
        )
    }
}

extension OutputRequestRaw {
    enum State: String, Codable {
        case ok
        case error
    }
}
