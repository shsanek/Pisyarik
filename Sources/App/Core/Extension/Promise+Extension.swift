import Foundation
import PromiseKit
import Vapor
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLSession {
    func dataPromise(with urlRequest: URLRequest) -> Promise<Data> {
        let result = Promise<Data>.pending()
        self.dataTask(with: urlRequest) { data, _, error in
            if let error = error {
                result.resolver.reject(error)
                return
            }
            if let data = data {
                result.resolver.fulfill(data)
                return
            }
            result.resolver.reject(NSError(domain: "SQL Empty data", code: 2, userInfo: nil))
        }.resume()
        return result.promise
    }
}

extension Promise {
    func mapResult<NewT>(_ map: @escaping (_ result: Result<T>) throws -> NewT) -> Promise<NewT> {
        let pending = Promise<NewT>.pending()
        self.done { value in
            do {
                let value = try map(.fulfilled(value))
                pending.resolver.fulfill(value)
            } catch {
                pending.resolver.reject(error)
            }
        }.catch { error in
            do {
                let value = try map(.rejected(error))
                pending.resolver.fulfill(value)
            } catch {
                pending.resolver.reject(error)
            }
        }
        return pending.promise
    }

    static func when(consistently promises: [Promise<Void>]) -> Promise<Void> {
        guard let first = promises.first else {
            return .value
        }
        let result = Promise<Void>.pending()
        let promises = promises.dropFirst()
        let handler = {
            _ = when(consistently: Array(promises)).done { _ in
                result.resolver.fulfill_()
            }.catch { _ in
                result.resolver.fulfill_()
            }
        }
        first.done { _ in
            handler()
        }.catch { _ in
            handler()
        }
        return result.promise
    }
}

extension Promise where T: RandomAccessCollection {
    var only: Promise<T.Element> {
        self.map { value -> T.Element in
            if value.count == 1, let value = value.first {
                return value
            }
            throw NSError(domain: "Not one element", code: 4, userInfo: nil)
        }
    }
}

extension Promise {
    func handler(_ block: @escaping (T) throws -> Void) -> Promise<T> {
        self.map { result -> T in
            try block(result)
            return result
        }
    }
}

extension Promise {
    func toFeature(_ eventLoop: EventLoop) -> EventLoopFuture<T> {
        let promise: EventLoopPromise<T> = eventLoop.makePromise()
        self.done { result in
            promise.succeed(result)
        }.catch { error in
            promise.fail(error)
        }
        return promise.futureResult
    }
}
