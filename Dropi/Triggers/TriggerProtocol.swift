import AppKit

protocol ShelfTrigger: AnyObject {
    var isEnabled: Bool { get set }
    var onTrigger: ((NSPoint) -> Void)? { get set }
    func start()
    func stop()
}
