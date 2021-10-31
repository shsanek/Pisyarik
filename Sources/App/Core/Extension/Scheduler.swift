import Foundation

final class Scheduler {

    var isRunning: Bool {
        return self.item != nil
    }
    private let defaultDelay: TimeInterval
    private let needAutoRetain: Bool

    private var autoRetain: Scheduler? = nil
    private var item: DispatchWorkItem?

    init(defaultDelay: TimeInterval, needAutoRetain: Bool = false) {
        self.defaultDelay = defaultDelay
        self.needAutoRetain = needAutoRetain
    }

    deinit {
        self.cancel()
    }

    func schedule(delay: TimeInterval, handler: @escaping () -> Void) {
        self.item?.cancel()
        if self.needAutoRetain {
            self.autoRetain = self
        }
        let item = DispatchWorkItem(block: { [weak self] in
            handler()
            self?.item = nil
            self?.autoRetain = nil
        })
        self.item = item
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: item)
    }

    func schedule(handler: @escaping () -> Void) {
        self.schedule(delay: self.defaultDelay, handler: handler)
    }

    func cancel() {
        self.item?.cancel()
        self.item = nil
        self.autoRetain = nil
    }
}
