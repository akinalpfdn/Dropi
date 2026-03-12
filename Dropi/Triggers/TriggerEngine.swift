import AppKit

@MainActor
final class TriggerEngine {
    private let hotkey = HotkeyTrigger()
    private let edge = EdgeTrigger()
    private let shake = ShakeTrigger()

    private var triggers: [ShelfTrigger] { [hotkey, edge, shake] }

    var onTrigger: ((NSPoint) -> Void)? {
        didSet {
            triggers.forEach { $0.onTrigger = onTrigger }
        }
    }

    func start() {
        guard Permissions.isAccessibilityGranted else {
            Permissions.requestAccessibility()
            return
        }
        triggers.forEach { $0.start() }
    }

    func stop() {
        triggers.forEach { $0.stop() }
    }

    func setHotkeyEnabled(_ enabled: Bool) { hotkey.isEnabled = enabled }
    func setEdgeEnabled(_ enabled: Bool) { edge.isEnabled = enabled }
    func setShakeEnabled(_ enabled: Bool) { shake.isEnabled = enabled }
}
