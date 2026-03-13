import AppKit
import SwiftUI

struct MultiFileDragSource: NSViewRepresentable {
    let urls: [URL]
    var onDragCompleted: (([URL]) -> Void)?
    var onTap: ((Bool) -> Void)?

    func makeNSView(context: Context) -> MultiFileDragNSView {
        MultiFileDragNSView()
    }

    func updateNSView(_ nsView: MultiFileDragNSView, context: Context) {
        nsView.urls = urls
        nsView.onDragCompleted = onDragCompleted
        nsView.onTap = onTap
    }
}

final class MultiFileDragNSView: NSView, NSDraggingSource {
    var urls: [URL] = []
    var onDragCompleted: (([URL]) -> Void)?
    var onTap: ((Bool) -> Void)?

    private var mouseDownLocation: NSPoint?
    private let dragThreshold: CGFloat = 4.0

    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        context == .outsideApplication ? [.copy, .move] : .move
    }

    func draggingSession(
        _ session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        operation: NSDragOperation
    ) {
        guard operation != [] else { return }
        let shelfWindow = NSApp.windows.first(where: { $0 is ShelfWindow })
        let droppedOnShelf = shelfWindow?.frame.contains(screenPoint) ?? false
        if !droppedOnShelf {
            onDragCompleted?(urls)
        }
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startLocation = mouseDownLocation, !urls.isEmpty else { return }
        let current = event.locationInWindow
        let dx = current.x - startLocation.x
        let dy = current.y - startLocation.y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance >= dragThreshold else { return }
        mouseDownLocation = nil

        let draggingItems = urls.map { url -> NSDraggingItem in
            let item = NSDraggingItem(pasteboardWriter: url as NSURL)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 48, height: 48)
            item.setDraggingFrame(NSRect(x: 0, y: 0, width: 48, height: 48), contents: icon)
            return item
        }

        beginDraggingSession(with: draggingItems, event: event, source: self)
    }

    override func mouseUp(with event: NSEvent) {
        guard mouseDownLocation != nil else { return }
        mouseDownLocation = nil
        let cmdPressed = event.modifierFlags.contains(.command)
        onTap?(cmdPressed)
    }
}
