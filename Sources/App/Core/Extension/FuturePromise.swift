import Vapor
import Foundation

func firstly<Value>(_ block: () throws -> FuturePromise<Value>) -> FuturePromise<Value> {
    do {
        return try block()
    } catch {
        return .error(error)
    }
}

func firstly<Value>(_ block: @escaping () throws -> EventLoopFuture<Value>) -> FuturePromise<Value> {
    return FuturePromise(maker: { _ in try block() })
}

struct FuturePromise<Value> {
    typealias Future = EventLoopFuture<Value>

    private let maker: (EventLoop) throws -> Future

    func make(_ eventLoop: EventLoop) throws -> Future {
        return try maker(eventLoop)
    }

    init(maker: @escaping (EventLoop) throws -> Future) {
        self.maker = maker
    }
}

extension FuturePromise {
    func asVoid() -> FuturePromise<Void> {
        self.map { _ in Void() }
    }

    func get(_ block: @escaping (Value) -> Void) -> FuturePromise<Value> {
        self.handle { value in
            DispatchQueue.global().async {
                block(value)
            }
        }
    }
}

extension FuturePromise {
    static func value(_ value: Value) -> Self {
        FuturePromise { eventLoop in
            let promise: EventLoopPromise<Value> = eventLoop.makePromise()
            promise.succeed(value)
            return promise.futureResult
        }
    }
    static func error(_ error: Error) -> Self {
        FuturePromise { eventLoop in
            let promise: EventLoopPromise<Value> = eventLoop.makePromise()
            promise.fail(error)
            return promise.futureResult
        }
    }
}

extension FuturePromise where Value == Void {
    static func when(consistently promises: [EventLoopFuture<Void>]) -> Self {
        FuturePromise<Void> {
            EventLoopFuture<Void>.when(consistently: promises, eventLoop: $0)
        }
    }

    static func when(consistently promises: [FuturePromise<Void>]) -> Self {
        FuturePromise<Void> { eventLoop in
            try EventLoopFuture<Void>.when(consistently: promises.map { try $0.maker(eventLoop) }, eventLoop: eventLoop)
        }
    }

}
extension FuturePromise {
    func mapError(_ map: @escaping (Error) -> Error) -> FuturePromise<Value> {
        return FuturePromise<Value> {
            try maker($0).mapError(map)
        }
    }

    func map<NewValue>(_ block: @escaping (Value) throws -> NewValue) -> FuturePromise<NewValue> {
        return FuturePromise<NewValue> {
            try maker($0).tryMap(block)
        }
    }
    
    func map<NewValue>(_ block: @escaping (Value) throws -> FuturePromise<NewValue>) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> { eventLoop in
            try maker(eventLoop).tryFlatMap { try block($0).maker(eventLoop) }
        }
    }

    func handle(_ block: @escaping (Value) throws -> Void) -> FuturePromise<Value> {
        FuturePromise<Value> {
            try maker($0).tryHandle(block)
        }
    }

    func mapResult<NewValue>(
        _ map: @escaping (_ result: Result<Value, Error>) throws -> NewValue
    ) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> {
            try maker($0).tryMapResult(map)
        }
    }

    func next<NewValue>(_ block: @escaping () throws -> EventLoopFuture<NewValue>) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> { eventLoop in
            try maker(eventLoop).tryNext(block)
        }
    }

    func next<NewValue>(_ block: @escaping () throws -> FuturePromise<NewValue>) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> { eventLoop in
            try maker(eventLoop).tryNext { try block().maker(eventLoop) }
        }
    }

    func then<NewValue>(_ block: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> { eventLoop in
            try maker(eventLoop).tryFlatMap { try block($0) }
        }
    }

    func then<NewValue>(_ block: @escaping (Value) throws -> FuturePromise<NewValue>) -> FuturePromise<NewValue> {
        FuturePromise<NewValue> { eventLoop in
            try maker(eventLoop).tryFlatMap { try block($0).maker(eventLoop) }
        }
    }
}

extension FuturePromise where Value: RandomAccessCollection {
    func only(file: String = #file, line: Int = #line) -> FuturePromise<Value.Element> {
        FuturePromise<Value.Element> { eventLoop in
            try maker(eventLoop).only(file: file, line: line)
        }
    }

    func first(file: String = #file, line: Int = #line) -> FuturePromise<Value.Element> {
        FuturePromise<Value.Element> { eventLoop in
            try maker(eventLoop).tryMap { value -> Value.Element in
                guard let first = value.first else {
                    throw Errors.internalError.description("первого элемента нет", file: file, line: line)
                }
                return first
            }
        }
    }
}

extension FuturePromise where Value: Encodable {
    func mapToResponse(requestId: String?, method: String) -> FuturePromise<String> {
        self.mapResult { result -> String in
            do {
                switch result {
                case.success(let object):
                    let raw = OutputRequestRaw.ok(object, requestId: requestId, method: method)
                    return try self.makeBodyText(raw)
                case .failure(let error):
                    let raw = OutputRequestRaw<EmptyRaw>.errors([error], requestId: requestId, method: method)
                    return try self.makeBodyText(raw)
                }
            } catch {
                return UserError.defaultError
            }
        }
    }

    private func makeBodyText<Output: Encodable>(_ value: Output) throws -> String {
        let outputData = try JSONEncoder().encode(value)
        if
            let text = String(data: outputData, encoding: .utf8)
        {
            return text
        } else {
            return UserError.defaultError
        }
    }
}
