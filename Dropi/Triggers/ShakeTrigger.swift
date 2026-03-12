import AppKit

final class ShakeTrigger: ShelfTrigger {
    var isEnabled: Bool = true
    var onTrigger: ((NSPoint) -> Void)?

    private var monitor: Any?
    private var directionChanges: [Date] = []
    private var lastDirection: Int = 0
    private var cooldownUntil: Date = .distantPast

    private let requiredChanges = 3
    private let timeWindow: TimeInterval = 0.5
    private let minimumDelta: CGFloat = 5.0
    private let cooldownDuration: TimeInterval = 1.0

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDragged]) { [weak self] event in
            self?.handle(event)
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        directionChanges.removeAll()
        lastDirection = 0
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
