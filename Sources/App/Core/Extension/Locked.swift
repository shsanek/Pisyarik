import Foundation

public final class Lock {

    // MARK: - Private

    private var lock = pthread_rwlock_t()

    // MARK: - Lifecycle

    public init() {
        pthread_rwlock_init(&lock, nil)
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    // MARK: - Public

    public func lockReading() {
        pthread_rwlock_rdlock(&lock)
    }

    public func lockWriting() {
        pthread_rwlock_wrlock(&lock)
    }

    public func unlock() {
        pthread_rwlock_unlock(&lock)
    }

}

@propertyWrapper
public class Locked<Value> {

    // MARK: - Private

    private var value: Value
    private let lock: Lock

    // MARK: - Lifecycle

    public init(wrappedValue: Value, lock: Lock = .init()) {
        value = wrappedValue
        self.lock = lock
    }

    // MARK: - Public

    public var wrappedValue: Value {
        get {
            lock.lockReading()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lockWriting()
            defer { lock.unlock() }
            value = newValue
        }
    }

    public var projectedValue: Locked<Value> {
        self
    }

    public func mutate(_ mutation: (inout Value) -> Void) {
        lock.lockWriting()
        defer { lock.unlock() }
        mutation(&value)
    }
}
