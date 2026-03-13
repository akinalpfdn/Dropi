import AppKit
import Combine
import ServiceManagement

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var hotkeyEnabled: Bool {
        didSet { UserDefaults.standard.set(hotkeyEnabled, forKey: Keys.hotkeyEnabled) }
    }
    @Published var edgeEnabled: Bool {
        didSet { UserDefaults.standard.set(edgeEnabled, forKey: Keys.edgeEnabled) }
    }
    @Published var shakeEnabled: Bool {
        didSet { UserDefaults.standard.set(shakeEnabled, forKey: Keys.shakeEnabled) }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLoginItem()
        }
    }
    @Published var showMenuBarIcon: Bool {
        didSet {
            UserDefaults.standard.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
            onMenuBarChanged?(showMenuBarIcon)
        }
    }
    @Published var hotkeyKeyCode: UInt16 {
        didSet { UserDefaults.standard.set(Int(hotkeyKeyCode), forKey: Keys.hotkeyKeyCode) }
    }
    @Published var hotkeyModifiers: Int {
        didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: Keys.hotkeyModifiers) }
    }

    var onMenuBarChanged: ((Bool) -> Void)?

    var modifierFlags: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: UInt(hotkeyModifiers))
    }

    var hotkeyDisplayString: String {
        var parts: [String] = []
        let flags = modifierFlags
        if flags.contains(.control) { parts.append("⌃") }
        if flags.contains(.option) { parts.append("⌥") }
        if flags.contains(.shift) { parts.append("⇧") }
        if flags.contains(.command) { parts.append("⌘") }
        parts.append(keyCodeToString(hotkeyKeyCode))
        return parts.joined()
    }

    private init() {
        let defaults = UserDefaults.standard
        let defaultModifiers = NSEvent.ModifierFlags([.command, .shift]).rawValue

        hotkeyEnabled = defaults.object(forKey: Keys.hotkeyEnabled) as? Bool ?? true
        edgeEnabled = defaults.object(forKey: Keys.edgeEnabled) as? Bool ?? true
        shakeEnabled = defaults.object(forKey: Keys.shakeEnabled) as? Bool ?? true
        launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        showMenuBarIcon = defaults.object(forKey: Keys.showMenuBarIcon) as? Bool ?? true
        hotkeyKeyCode = UInt16(defaults.object(forKey: Keys.hotkeyKeyCode) as? Int ?? 49)
        hotkeyModifiers = defaults.object(forKey: Keys.hotkeyModifiers) as? Int ?? Int(defaultModifiers)
    }

    func updateHotkey(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        hotkeyKeyCode = keyCode
        hotkeyModifiers = Int(modifiers.rawValue)
    }

    private func updateLoginItem() {
        try? SMAppService.mainApp.register()
        if !launchAtLogin {
            try? SMAppService.mainApp.unregister()
        }
    }

    private func keyCodeToString(_ keyCode: UInt16) -> String {
        let mapping: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            31: "O", 32: "U", 34: "I", 35: "P", 37: "L", 38: "J", 40: "K",
            45: "N", 46: "M", 49: "Space", 36: "↩", 48: "⇥", 51: "⌫",
            53: "⎋", 123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        return mapping[keyCode] ?? "Key\(keyCode)"
    }

    private enum Keys {
        static let hotkeyEnabled = "hotkeyEnabled"
        static let edgeEnabled = "edgeEnabled"
        static let shakeEnabled = "shakeEnabled"
        static let launchAtLogin = "launchAtLogin"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let hotkeyKeyCode = "hotkeyKeyCode"
        static let hotkeyModifiers = "hotkeyModifiers"
    }
}
