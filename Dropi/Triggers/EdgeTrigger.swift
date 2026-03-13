import AppKit

final class EdgeTrigger: ShelfTrigger {
    var isEnabled: Bool = true
    var onTrigger: ((NSPoint) -> Void)?

    private var dragMonitor: Any?
    private var mouseDownMonitor: Any?
    private var mouseUpMonitor: Any?
    private var dwellTimer: Timer?

    private var leftIndicator: EdgeIndicatorWindow?
    private var rightIndicator: EdgeIndicatorWindow?
    private var topIndicator: EdgeIndicatorWindow?
    private var indicatorsVisible = false

    private let edgeThreshold: CGFloat = 5.0
    private let proximityZone: CGFloat = 300.0
    private let dwellDuration: TimeInterval = 0.2

    func start() {
        let dragPasteboard = NSPasteboard(name: .drag)
        var changeCountAtDown = 0
        var isDraggingFile = false

        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            changeCountAtDown = dragPasteboard.changeCount
            isDraggingFile = false
        }

        dragMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] _ in
            guard let self, self.isEnabled else { return }

            if !isDraggingFile {
                guard dragPasteboard.changeCount > changeCountAtDown else { return }
                let hasFiles = dragPasteboard.canReadObject(forClasses: [NSURL.self], options: [
                    .urlReadingFileURLsOnly: true
                ])
                guard hasFiles else { return }
                isDraggingFile = true
                self.showIndicators()
            }

            self.handleDrag()
        }

        mouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] _ in
            isDraggingFile = false
            self?.hideIndicators()
            self?.dwellTimer?.invalidate()
            self?.dwellTimer = nil
        }
    }

    func stop() {
        [dragMonitor, mouseDownMonitor, mouseUpMonitor].compactMap { $0 }.forEach {
            NSEvent.removeMonitor($0)
        }
        dragMonitor = nil
        mouseDownMonitor = nil
        mouseUpMonitor = nil
        dwellTimer?.invalidate()
        dwellTimer = nil
        hideIndicators()
    }

    private func handleDrag() {
        guard let screen = NSScreen.main else { return }
        let loc = NSEvent.mouseLocation

        updateIndicatorProximity(location: loc, screen: screen)

        let atEdge = loc.x >= screen.frame.maxX - edgeThreshold
                  || loc.x <= screen.frame.minX + edgeThreshold
                  || loc.y >= screen.frame.maxY - edgeThreshold

        if atEdge {
            guard dwellTimer == nil else { return }
            dwellTimer = Timer.scheduledTimer(withTimeInterval: dwellDuration, repeats: false) { [weak self] _ in
                guard let self else { return }
                self.dwellTimer = nil
                self.hideIndicators()
                self.onTrigger?(NSEvent.mouseLocation)
            }
        } else {
            dwellTimer?.invalidate()
            dwellTimer = nil
        }
    }

    // MARK: - Indicators

    private func showIndicators() {
        guard !indicatorsVisible else { return }
        indicatorsVisible = true

        let left = EdgeIndicatorWindow(edge: .left)
        let right = EdgeIndicatorWindow(edge: .right)
        let top = EdgeIndicatorWindow(edge: .top)
        left.fadeIn()
        right.fadeIn()
        top.fadeIn()
        leftIndicator = left
        rightIndicator = right
        topIndicator = top
    }

    private func hideIndicators() {
        guard indicatorsVisible else { return }
        indicatorsVisible = false

        leftIndicator?.fadeOut { [weak self] in self?.leftIndicator = nil }
        rightIndicator?.fadeOut { [weak self] in self?.rightIndicator = nil }
        topIndicator?.fadeOut { [weak self] in self?.topIndicator = nil }
    }

    private func updateIndicatorProximity(location: NSPoint, screen: NSScreen) {
        let distToLeft = location.x - screen.frame.minX
        let distToRight = screen.frame.maxX - location.x
        let distToTop = screen.frame.maxY - location.y

        if distToLeft < proximityZone {
            leftIndicator?.updateProximity(1.0 - distToLeft / proximityZone)
        } else {
            leftIndicator?.updateProximity(0)
        }

        if distToRight < proximityZone {
            rightIndicator?.updateProximity(1.0 - distToRight / proximityZone)
        } else {
            rightIndicator?.updateProximity(0)
        }

        if distToTop < proximityZone {
            topIndicator?.updateProximity(1.0 - distToTop / proximityZone)
        } else {
            topIndicator?.updateProximity(0)
        }
    }
}
