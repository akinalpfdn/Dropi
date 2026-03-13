import AppKit

final class EdgeIndicatorWindow: NSPanel {
    enum Edge {
        case left, right, top
    }

    let edge: Edge
    private let glowLayer = CAGradientLayer()

    init(edge: Edge) {
        self.edge = edge

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let rect: NSRect

        switch edge {
        case .left:
            let w: CGFloat = 6
            let h: CGFloat = 240
            rect = NSRect(x: screen.frame.minX, y: screen.frame.midY - h / 2, width: w, height: h)

        case .right:
            let w: CGFloat = 6
            let h: CGFloat = 240
            rect = NSRect(x: screen.frame.maxX - w, y: screen.frame.midY - h / 2, width: w, height: h)

        case .top:
            let menuBarHeight = screen.frame.maxY - screen.visibleFrame.maxY
            let hasNotch = menuBarHeight > 30
            let barWidth: CGFloat = hasNotch ? 260 : 200
            let barHeight: CGFloat = 6
            rect = NSRect(
                x: screen.frame.midX - barWidth / 2,
                y: screen.frame.maxY - barHeight,
                width: barWidth,
                height: barHeight
            )
        }

        super.init(
            contentRect: rect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        level = .screenSaver
        isFloatingPanel = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        alphaValue = 0

        setupGlow(size: rect.size)
    }

    private func setupGlow(size: NSSize) {
        let hostView = NSView(frame: NSRect(origin: .zero, size: size))
        hostView.wantsLayer = true

        glowLayer.frame = hostView.bounds

        let accent = NSColor.controlAccentColor.withAlphaComponent(0.8).cgColor
        let transparent = NSColor.clear.cgColor

        switch edge {
        case .left, .right:
            glowLayer.cornerRadius = size.width / 2
            glowLayer.colors = [transparent, accent, accent, transparent]
            glowLayer.locations = [0.0, 0.3, 0.7, 1.0]
            glowLayer.startPoint = CGPoint(x: 0.5, y: 0)
            glowLayer.endPoint = CGPoint(x: 0.5, y: 1)

        case .top:
            glowLayer.cornerRadius = size.height / 2
            glowLayer.colors = [transparent, accent, accent, transparent]
            glowLayer.locations = [0.0, 0.2, 0.8, 1.0]
            glowLayer.startPoint = CGPoint(x: 0, y: 0.5)
            glowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }

        glowLayer.shadowColor = NSColor.controlAccentColor.cgColor
        glowLayer.shadowRadius = 24
        glowLayer.shadowOpacity = 1.0
        glowLayer.shadowOffset = .zero

        hostView.layer?.addSublayer(glowLayer)
        contentView = hostView
    }

    func fadeIn() {
        orderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1.0
        }
    }

    func fadeOut(completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            animator().alphaValue = 0
        }, completionHandler: {
            self.orderOut(nil)
            completion?()
        })
    }

    func updateProximity(_ proximity: CGFloat) {
        let clamped = max(0, min(1, proximity))
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.05
            animator().alphaValue = 0.5 + clamped * 0.5
        }
    }
}
