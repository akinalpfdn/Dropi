import AppKit

final class HotkeyTrigger: ShelfTrigger {
    var isEnabled: Bool = true
    var onTrigger: ((NSPoint) -> Void)?

    private var monitor: Any?

    // ⌘ + Shift + Space
    private let keyCode: UInt16 = 49
    private let modifiers: NSEvent.ModifierFlags = [.command, .shift]

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.isEnabled else { return }
            let pressed = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if event.keyCode == self.keyCode && pressed == self.modifiers {
                self.onTrigger?(NSEvent.mouseLocation)
            }
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
