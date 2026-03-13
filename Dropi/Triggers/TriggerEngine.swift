import AppKit
import Combine

@MainActor
final class TriggerEngine {
    private let hotkey = HotkeyTrigger()
    private let edge = EdgeTrigger()
    private let shake = ShakeTrigger()

    private var triggers: [ShelfTrigger] { [hotkey, edge, shake] }
    private var cancellables = Set<AnyCancellable>()

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
        applySettings()
        observeSettings()
        triggers.forEach { $0.start() }
    }

    func stop() {
        triggers.forEach { $0.stop() }
        cancellables.removeAll()
    }

    private func applySettings() {
        let settings = AppSettings.shared
        hotkey.isEnabled = settings.hotkeyEnabled
        hotkey.keyCode = settings.hotkeyKeyCode
        hotkey.modifiers = settings.modifierFlags
        edge.isEnabled = settings.edgeEnabled
        shake.isEnabled = settings.shakeEnabled
    }

    private func observeSettings() {
        let settings = AppSettings.shared

        settings.$hotkeyEnabled
            .sink { [weak self] in self?.hotkey.isEnabled = $0 }
            .store(in: &cancellables)

        settings.$edgeEnabled
            .sink { [weak self] in self?.edge.isEnabled = $0 }
            .store(in: &cancellables)

        settings.$shakeEnabled
            .sink { [weak self] in self?.shake.isEnabled = $0 }
            .store(in: &cancellables)

        settings.$hotkeyKeyCode
            .sink { [weak self] in self?.hotkey.keyCode = $0 }
            .store(in: &cancellables)

        settings.$hotkeyModifiers
            .sink { [weak self] modifiers in
                self?.hotkey.modifiers = NSEvent.ModifierFlags(rawValue: UInt(modifiers))
            }
            .store(in: &cancellables)
    }
}
