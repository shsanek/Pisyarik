import Foundation
import MySQLKit
import Vapor

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class DataBase {
    var version: Int?

    private lazy var pools = EventLoopGroupConnectionPool(
        source: MySQLConnectionSource(configuration: configuration),
        on: app.eventLoopGroup
    )

    private var configuration: MySQLConfiguration {
        MySQLConfiguration(
            hostname: "127.0.0.1",
            username: "user",
            password: "123",
            database: "arrle",
            tlsConfiguration: nil
        )
    }

    private let app: Application

    init(_ app: Application) {
        self.app = app
    }

    private func perform<Result: Decodable>(_ request: String, description: String) -> FuturePromise<[Result]> {
        var requests = request.components(separatedBy: ";").filter {
            $0.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: " ", with: "").count > 0
        }.map { $0 + ";" }
        guard requests.count > 0 else {
            return .error(Errors.internalError.description("sql реквест пуст"))
        }
        let last = requests.removeLast()
        return FuturePromise<[Result]> { eventLoop in
            self.pools.withConnection(logger: self.app.logger) { connection in
                EventLoopFuture<Void>.when(
                    consistently: requests.map { connection.simpleQuery($0).map { _ in Void() } },
                    eventLoop: eventLoop,
                    skipError: false
                ).tryNext {
                    connection.simpleQuery(last).tryMap { row  in
                        do {
                            return try row.map {
                                try $0.sql(
                                    decoder: MySQLDataDecoder(json: JSONDecoder())
                                ).decode(model: Result.self)
                            }
                        }
                        catch {
                            print(last)
                            print(error)
                            throw error
                        }
                    }
                }
            }
        }.mapError { error in
            let error = Errors.sqlError.description("Произошла ошибка при запросе к БД", error: error)
            return error
        }
    }

    func migration(versions: [SQLVersion]) -> FuturePromise<Void> {
        firstly {
            self.run(request: DBGetVersionRequest())
        }.only().mapResult { result -> Int in
            switch result {
            case .success(let value):
                return value.version
            default:
                return 0
            }
        }.then { version -> FuturePromise<Void>  in
            guard version < versions.count else {
                return .value(Void())
            }
            var promises = [FuturePromise<Void>]()
            for i in version..<versions.count {
                promises.append(
                    self.request(
                        description: "Migration to version \(i)",
                        request: versions[i].migrationRequests,
                        type: EmptyRaw.self
                    ).asVoid()
                )
            }
            return FuturePromise<Void>.when(consistently: promises)
        }.next {
            self.run(request: DBUpdateVersionRequest(version: versions.count)).asVoid().get { _ in
                self.version = versions.count
            }
        }
    }

    func request<Result: Decodable>(
        description: String,
        request: String,
        type: Result.Type
    ) -> FuturePromise<[Result]> {
        return self.perform(request, description: request.description)
    }
}

extension DataBase: IDataBase {
    func run<Request: IDBRequest>(request: Request) -> FuturePromise<[Request.Result]> {
        do {
            return self.perform(try request.request(), description: request.description)
        } catch {
            return .error(error)
        }
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
    func run<Request: IDBRequest>(request: Request) -> FuturePromise<[Request.Result]>
}

protocol IDBRequest {
    associatedtype Result: Decodable

    var description: String { get }
    func request() throws -> String
}
