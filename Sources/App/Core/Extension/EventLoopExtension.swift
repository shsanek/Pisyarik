import Vapor
import Foundation

extension EventLoopFuture {
    func mapError(_ map: @escaping (Error) -> Error) -> EventLoopFuture<Value> {
        let promise: EventLoopPromise<Value> = eventLoop.makePromise()
        self.whenComplete { result in
            switch result {
            case .success(let value):
                promise.succeed(value)
            case .failure(let error):
                promise.fail(map(error))
            }
        }
        return promise.futureResult
    }

    func tryMap<NewValue>(_ block: @escaping (Value) throws -> NewValue) -> EventLoopFuture<NewValue> {
        self.tryFlatMap { [eventLoop] value in
            let newValue = try block(value)
            let promise: EventLoopPromise<NewValue> = eventLoop.makePromise()
            promise.succeed(newValue)
            return promise.futureResult
        }
    }

    func tryHandle(_ block: @escaping (Value) throws -> Void) -> EventLoopFuture<Value> {
        self.tryFlatMap { [eventLoop] value in
            try block(value)
            let promise: EventLoopPromise<Value> = eventLoop.makePromise()
            promise.succeed(value)
            return promise.futureResult
        }
    }

    func tryNext<NewValue>(_ block: @escaping () throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        self.tryFlatMap { _ in
            try block()
        }
    }
}

extension EventLoopFuture {
    func tryMapResult<NewT>(_ map: @escaping (_ result: Result<Value, Error>) throws -> NewT) -> EventLoopFuture<NewT> {
        let promise: EventLoopPromise<NewT> = eventLoop.makePromise()
        self.whenComplete { result in
            do {
                promise.succeed(try map(result))
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    static func when(
        consistently promises: [EventLoopFuture<Void>],
        eventLoop: EventLoop,
        skipError: Bool = true
    ) -> EventLoopFuture<Void> {
        let promise: EventLoopPromise<Void> = eventLoop.makePromise()
        guard let first = promises.first else {
            promise.succeed(Void())
            return promise.futureResult
        }
        let promises = Array(promises.dropFirst())
        first.whenComplete { result in
            if case .failure(let error) = result, skipError == false {
                promise.fail(error)
                return
            }
            when(consistently: promises, eventLoop: eventLoop).whenComplete { result in
                if case .failure(let error) = result, skipError == false {
                    promise.fail(error)
                    return
                }
                promise.succeed(Void())
            }
        }
        return promise.futureResult
    }
}

extension EventLoopFuture where Value: RandomAccessCollection {
    func only(file: String = #file, line: Int = #line) -> EventLoopFuture<Value.Element> {
        self.tryMap { value -> Value.Element in
            if value.count == 1, let value = value.first {
                return value
            }
            throw Errors.internalError.description("количество обьектов не равно 1", file: file, line: line)
        }
    }
}

extension EventLoopPromise {
    func end(_ result: Result<Value, Error>) {
        switch result {
        case .success(let value):
            self.succeed(value)
        case .failure(let error):
            self.fail(error)
        }
    }
}
