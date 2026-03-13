import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private(set) var shelfManager: ShelfManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        shelfManager = ShelfManager()
        setupMenuBar()
        bindSettings()
    }

    private func setupMenuBar() {
        let settings = AppSettings.shared
        if settings.showMenuBarIcon {
            showMenuBarIcon()
        }
    }

    private func bindSettings() {
        AppSettings.shared.onMenuBarChanged = { [weak self] show in
            if show {
                self?.showMenuBarIcon()
            } else {
                self?.hideMenuBarIcon()
            }
        }
    }

    private func showMenuBarIcon() {
        guard statusItem == nil else { return }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else { return }
        let icon = NSImage(named: "MenuBarIcon") ?? NSImage(systemSymbolName: "tray.and.arrow.down.fill", accessibilityDescription: "Dropi")
        icon?.size = NSSize(width: 18, height: 18)
        icon?.isTemplate = true
        button.image = icon
        button.action = #selector(toggleShelf)
        button.target = self
    }

    private func hideMenuBarIcon() {
        guard let item = statusItem else { return }
        NSStatusBar.system.removeStatusItem(item)
        statusItem = nil
    }

    @objc private func toggleShelf() {
        shelfManager?.toggle()
    }
}
