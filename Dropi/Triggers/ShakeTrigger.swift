import AppKit

final class ShakeTrigger: ShelfTrigger {
    var isEnabled: Bool = true
    var onTrigger: ((NSPoint) -> Void)?

    private var dragMonitor: Any?
    private var mouseDownMonitor: Any?
    private var mouseUpMonitor: Any?

    private var directionChanges: [Date] = []
    private var lastDirection: Int = 0
    private var cooldownUntil: Date = .distantPast

    private var changeCountAtMouseDown: Int = 0
    private var isDraggingFile = false

    private let requiredChanges = 3
    private let timeWindow: TimeInterval = 0.5
    private let minimumDelta: CGFloat = 5.0
    private let cooldownDuration: TimeInterval = 1.0

    func start() {
        let dragPasteboard = NSPasteboard(name: .drag)

        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            self?.changeCountAtMouseDown = dragPasteboard.changeCount
            self?.isDraggingFile = false
            self?.directionChanges.removeAll()
            self?.lastDirection = 0
        }

        dragMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event in
            guard let self else { return }
            if !self.isDraggingFile {
                let newCount = dragPasteboard.changeCount
                guard newCount > self.changeCountAtMouseDown else { return }
                let hasFiles = dragPasteboard.canReadObject(forClasses: [NSURL.self], options: [
                    .urlReadingFileURLsOnly: true
                ])
                guard hasFiles else { return }
                self.isDraggingFile = true
            }
            self.handle(event)
        }

        mouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] _ in
            self?.isDraggingFile = false
            self?.directionChanges.removeAll()
            self?.lastDirection = 0
        }
    }

    func stop() {
        [dragMonitor, mouseDownMonitor, mouseUpMonitor].compactMap { $0 }.forEach {
            NSEvent.removeMonitor($0)
        }
        dragMonitor = nil
        mouseDownMonitor = nil
        mouseUpMonitor = nil
        directionChanges.removeAll()
        lastDirection = 0
        isDraggingFile = false
    }

    private func handle(_ event: NSEvent) {
        guard isEnabled, Date() > cooldownUntil else { return }
        guard abs(event.deltaX) >= minimumDelta else { return }

        let direction = event.deltaX > 0 ? 1 : -1
        guard direction != lastDirection, lastDirection != 0 else {
            lastDirection = direction
            return
        }
        lastDirection = direction

        let now = Date()
        directionChanges.append(now)
        directionChanges.removeAll { now.timeIntervalSince($0) > timeWindow }

        if directionChanges.count >= requiredChanges {
            cooldownUntil = now.addingTimeInterval(cooldownDuration)
            directionChanges.removeAll()
            onTrigger?(NSEvent.mouseLocation)
        }
    }
}
