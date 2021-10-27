import Foundation
import PromiseKit
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class DataBase {
    var version: Int?

    private let address = "http://localhost:4001"
    private let session = URLSession(configuration: .default)
    
    func migration(versions: [SQLVersion]) -> Promise<Void> {
        self.run(request: DBGetVersionRequest()).firstValue.mapResult { (result: Result<DBVersionDTO>) -> Int in
            switch result {
            case .fulfilled(let value):
                return value.version
            default:
                return 0
            }
        }.then { version -> Promise<Void> in
            guard version < versions.count else {
                return .value
            }
            var promises = [Promise<Void>]()
            for i in version..<versions.count {
                promises.append(
                    self.request(
                        description: "Migration to version \(i)",
                        request: versions[i].migrationRequests,
                        type: EmptyRaw.self
                    ).asVoid()
                )
            }
            return Promise<Void>.when(consistently: promises)
        }.then { _ -> Promise<Void>  in
            self.run(request: DBUpdateVersionRequest(version: versions.count)).asVoid().get { _ in
                self.version = versions.count
            }
        }
    }
    
    func request<Result: Decodable>(description: String, request: String, type: Result.Type) -> Promise<[Result]> {
        return self.request(description: description, request: request)
    }
    
    func request<Result: Decodable>(description: String, request: String) -> Promise<[Result]> {
        let result = Promise<[Result]>.pending()
        do {
            guard let url = URL(string: address) else {
                throw NSError(
                    domain: "SQL error",
                    code: 2,
                    userInfo: ["request description": description]
                )
            }
            let raw = SQLRequestResultRaw(
                request: request
            )
            var urlRequest = URLRequest(url: url)
            let data = try JSONEncoder().encode(raw)
            urlRequest.httpBody = data
            urlRequest.httpMethod = "POST"
            return session.dataPromise(with: urlRequest).map { data in
                try JSONDecoder().decode(SQLResponseRaw<Result>.self, from: data)
            }.map { (result: SQLResponseRaw<Result>) -> [Result] in
                if let content = result.content {
                    return content
                }
                if let error = result.error {
                    throw NSError(
                        domain: "SQL error",
                        code: 2,
                        userInfo: ["SQL": error, "request description": description]
                    )
                }
                throw NSError(
                    domain: "SQL error",
                    code: 2,
                    userInfo: ["request description": description]
                )
            }
        }
        catch {
            result.resolver.reject(error)
        }
        return result.promise
    }
}

extension DataBase: IDataBase {    
    func run<Request: IDBRequest>(request: Request) -> Promise<[Request.Result]> {
        return self.request(description: request.description, request: request.request)
    }
}

struct DBVersionDTO: Decodable {
    let version: Int
}

struct SQLVersion {
    let migrationRequests: String
}

struct SQLRequestResultRaw: Codable {
    let request: String
}

struct SQLResponseRaw<Result: Decodable>: Decodable {
    let content: [Result]?
    let error: String?
}

protocol IDataBase {
    func run<Request: IDBRequest>(request: Request) -> Promise<[Request.Result]>
}

protocol IDBRequest {
    associatedtype Result: Decodable
    var description: String { get }
    var request: String { get }
}
