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