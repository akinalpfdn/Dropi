import AppKit

@MainActor
final class ShelfManager {
    private var window: ShelfWindow?

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
        let rect = NSRect(x: 0, y: 0, width: Constants.Shelf.defaultWidth, height: Constants.Shelf.defaultHeight)
        let panel = ShelfWindow(contentRect: rect)
        panel.contentViewController = ShelfViewController()
        window = panel
    }

    private func position(_ window: NSWindow, near point: NSPoint?) {
        guard let screen = NSScreen.main else { return }
        let w = Constants.Shelf.defaultWidth
        let h = Constants.Shelf.defaultHeight
        let origin = point ?? NSPoint(x: screen.frame.midX - w / 2, y: screen.frame.midY - h / 2)

        let x = min(max(origin.x - w / 2, screen.visibleFrame.minX), screen.visibleFrame.maxX - w)
        let y = min(max(origin.y - h / 2, screen.visibleFrame.minY), screen.visibleFrame.maxY - h)
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
