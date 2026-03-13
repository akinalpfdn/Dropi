import AppKit

class ShelfWindow: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        level = .floating
        isFloatingPanel = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = false
        animationBehavior = .utilityWindow

    }

    override var contentViewController: NSViewController? {
        didSet {
            contentView?.wantsLayer = true
            contentView?.layer?.cornerRadius = Constants.Shelf.cornerRadius
            contentView?.layer?.masksToBounds = true
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown, .rightMouseDown:
            if !isKeyWindow { makeKey() }
            super.sendEvent(event)
        default:
            super.sendEvent(event)
        }
    }
}
