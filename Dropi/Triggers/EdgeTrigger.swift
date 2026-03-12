import AppKit

final class EdgeTrigger: ShelfTrigger {
    var isEnabled: Bool = true
    var onTrigger: ((NSPoint) -> Void)?

    private var monitor: Any?
    private var dwellTimer: Timer?
    private let edgeThreshold: CGFloat = 5.0
    private let dwellDuration: TimeInterval = 0.3

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] _ in
            self?.handleDrag()
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        dwellTimer?.invalidate()
        dwellTimer = nil
    }

    private func handleDrag() {
        guard isEnabled, let screen = NSScreen.main else { return }
        let loc = NSEvent.mouseLocation

        let atEdge = loc.x >= screen.frame.maxX - edgeThreshold
                  || loc.x <= screen.frame.minX + edgeThreshold

        if atEdge {
            guard dwellTimer == nil else { return }
            dwellTimer = Timer.scheduledTimer(withTimeInterval: dwellDuration, repeats: false) { [weak self] _ in
                guard let self else { return }
                self.dwellTimer = nil
                self.onTrigger?(NSEvent.mouseLocation)
            }
        } else {
            dwellTimer?.invalidate()
            dwellTimer = nil
        }
    }
}
