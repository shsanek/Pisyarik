import PromiseKit
import Foundation

final class LazyRequest<Element> {

    // MARK: - Properties

    private var completionHandlers: [Handler] = []
    private var promiseMaker: () -> Promise<Element>
    private var load = false
    private var lock = pthread_rwlock_t()

    // MARK: - Init

    init(_ maker: @escaping () -> Promise<Element>) {
        pthread_rwlock_init(&lock, nil)
        promiseMaker = maker
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
}

extension LazyRequest {
    func promise() -> Promise<Element> {
        Promise { resolver in
            self.schedule { resolver.resolve($0) }
        }
    }
}

// MARK: - Private

private extension LazyRequest {
    func schedule(_ completion: @escaping Handler) {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        completionHandlers.append(completion)
        if load == false {
            start()
        }
    }

    func start() {
        promiseMaker().done { result in
            self.completion(.fulfilled(result))
        }.catch { error in
            self.completion(.rejected(error))
        }
        load = true
    }

    func completion(_ result: Result<Element>) {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        load = false
        completionHandlers.forEach { $0(result) }
        completionHandlers.removeAll()
    }
}

// MARK: - Nested Types

extension LazyRequest {
    typealias Handler = (Result<Element>) -> Void
}
