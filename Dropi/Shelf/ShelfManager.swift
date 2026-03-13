import AppKit

@MainActor
final class ShelfManager {
    private var window: ShelfWindow?
    private let triggerEngine = TriggerEngine()

    init() {
        triggerEngine.onTrigger = { [weak self] point in
            Task { @MainActor in self?.toggle(near: point) }
        }
        triggerEngine.start()
    }

    func show(near point: NSPoint? = nil) {
        if window == nil { createWindow() }
        guard let window, !window.isVisible else { return }
        position(window, near: point)
        window.makeKeyAndOrderFront(nil)
    }

    func hide() {
        window?.orderOut(nil)
    }

    func toggle(near point: NSPoint? = nil) {
        if let window, window.isVisible { hide() } else { show(near: point) }
    }

    private func createWindow() {
        let rect = NSRect(x: 0, y: 0, width: Constants.Shelf.compactWidth, height: Constants.Shelf.compactHeight)
        let panel = ShelfWindow(contentRect: rect)
        panel.contentViewController = ShelfViewController()
        window = panel
    }

    private func position(_ window: NSWindow, near point: NSPoint?) {
        guard let screen = NSScreen.main else { return }
        let w = Constants.Shelf.compactWidth
        let h = Constants.Shelf.compactHeight
        let origin = point ?? NSPoint(x: screen.frame.midX - w / 2, y: screen.frame.midY - h / 2)

        let x = min(max(origin.x - w / 2, screen.visibleFrame.minX), screen.visibleFrame.maxX - w)
        let y = min(max(origin.y - h / 2, screen.visibleFrame.minY), screen.visibleFrame.maxY - h)
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
