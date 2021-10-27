struct OutputRequestRaw<Output: Encodable>: Encodable {
    let state: State
    let content: Output?
    let errors: [UserError]?
}

extension OutputRequestRaw {
    static func ok(_ content: Output) -> Self {
        OutputRequestRaw(state: .ok, content: content, errors: nil)
    }

    static func errors(_ errors: [Error]) -> Self {
        OutputRequestRaw(state: .error, content: nil, errors: errors.map { $0.makeUserError() })
    }
}

extension OutputRequestRaw {
    enum State: String, Codable  {
        case ok
        case error
    }
}
