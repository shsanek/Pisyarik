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
            }.catch { error in
                result.resolver.fulfill_()
            }
        }
        first.done { _ in
            handler()
        }.catch { error in
            handler()
        }
        return result.promise
    }
}

extension Promise where T: RandomAccessCollection {
    var only: Promise<T.Element> {
        return self.map { value -> T.Element in
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

extension EventLoopPromise where Value == String {
    func ok<Output: Encodable>(_ content: Output) {
        let raw = OutputRequestRaw.ok(content)
        self.send(raw)
    }

    func errors(_ errors: [Error]) {
        let raw = OutputRequestRaw<EmptyRaw>.errors(errors)
        self.send(raw)
    }
    
    private func send<Output: Encodable>(_ value: Output) {
        if
            let outputData = try? JSONEncoder().encode(value),
            let text = String(data: outputData, encoding: .utf8)
        {
            self.succeed(text)
        }
        else
        {
            self.succeed(UserError.defaultError)
        }
    }
}

extension RequestParameters {
    var onlyLogin: Promise<Self> {
        Promise.value(self).map { result in
            if result.authorisationInfo == nil {
                throw UserError(
                    name: "available only for authorized users",
                    description: "available only for authorized users",
                    info: nil
                )
            }
            return result
        }
    }
    
    var getUser: Promise<AuthorisationInfo> {
        Promise { resolver in
            guard let info = self.authorisationInfo else {
                resolver.reject(UserError(
                    name: "available only for authorized users",
                    description: "available only for authorized users",
                    info: nil
                ))
                return
            }
            resolver.fulfill(info)
        }
    }
}
