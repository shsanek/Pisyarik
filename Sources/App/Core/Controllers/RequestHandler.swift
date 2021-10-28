import PromiseKit

protocol IRequestHandler {
    associatedtype Input: Decodable
    associatedtype Output: Encodable

    var name: String { get }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Result
}

extension IRequestHandler {
    typealias Result = Promise<Output>
}

struct AuthorisationInfo {
    let identifier: IdentifierType
    let name: String
}

struct RequestParameters<Input: Decodable> {
    let authorisationInfo: AuthorisationInfo?
    let input: Input
}
