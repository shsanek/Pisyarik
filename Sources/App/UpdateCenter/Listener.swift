import PromiseKit
import Foundation

final class Listener {
    let promise: Promise<[NotificationOutputContainer]>

    @Locked var active: Bool = false {
        didSet {
            self.update()
        }
    }

    private let task = UpdateTask()
    @Locked var containers: [NotificationOutputContainer] = []

    init(_ endBlock: @escaping (_ active: Bool) -> Void) {
        let pending = Promise<[NotificationOutputContainer]>.pending()
        self.promise = pending.promise
        self.active = false
        task.resault.done {
            endBlock(self.active)
            pending.resolver.fulfill(self.containers)
        }.catch { _ in
            endBlock(self.active)
            pending.resolver.fulfill(self.containers)
        }
    }
    
    func append(_ container: NotificationOutputContainer) {
        self.containers.append(container)

    }
    
    private func update() {
        guard self.active else { return }
        if containers.count > 20 {
            task.cancel()
        } else {
            task.update()
        }
    }
}


final class UpdateTask {
    let resault: Promise<Void>

    private let updateResolver: Resolver<Void>
    private let cancelResolver: Resolver<Void>

    private let scheduler = Scheduler(defaultDelay: 2)
    
    init(_ maxTime: Double = 30) {
        let updatePending = Promise<Void>.pending()
        let cancelPending = Promise<Void>.pending()
        self.updateResolver = updatePending.resolver
        self.cancelResolver = cancelPending.resolver
        let max: Promise<Void>  = after(seconds: maxTime).asVoid()
        self.resault = race([max, updatePending.promise, cancelPending.promise])
    }
    
    func update() {
        scheduler.schedule { [weak self] in
            self?.updateResolver.fulfill(())
        }
    }
    
    func cancel() {
        self.cancelResolver.fulfill(())
    }
}

public final class Scheduler
{

    internal var isRunning: Bool {
        return self.item != nil
    }
    private let defaultDelay: TimeInterval
    private let needAutoRetain: Bool

    private var autoRetain: Scheduler? = nil
    private var item: DispatchWorkItem?

    public init(defaultDelay: TimeInterval, needAutoRetain: Bool = false)
    {
        self.defaultDelay = defaultDelay
        self.needAutoRetain = needAutoRetain
    }

    deinit
    {
        self.cancel()
    }

    public func schedule(delay: TimeInterval, handler: @escaping () -> Void)
    {
        self.item?.cancel()
        if self.needAutoRetain
        {
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

    public func schedule(handler: @escaping () -> Void)
    {
        self.schedule(delay: self.defaultDelay, handler: handler)
    }

    public func cancel()
    {
        self.item?.cancel()
        self.item = nil
        self.autoRetain = nil
    }
}
