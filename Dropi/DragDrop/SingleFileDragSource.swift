import AppKit
import SwiftUI

struct SingleFileDragSource: NSViewRepresentable {
    let url: URL
    let thumbnail: NSImage?
    var onDragCompleted: (() -> Void)?

    func makeNSView(context: Context) -> SingleFileDragNSView {
        SingleFileDragNSView()
    }

    func updateNSView(_ nsView: SingleFileDragNSView, context: Context) {
        nsView.url = url
        nsView.thumbnail = thumbnail
        nsView.onDragCompleted = onDragCompleted
    }
}

final class SingleFileDragNSView: NSView, NSDraggingSource {
    var url: URL?
    var thumbnail: NSImage?
    var onDragCompleted: (() -> Void)?

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
            onDragCompleted?()
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard let url else {
            super.mouseDown(with: event)
            return
        }

        let item = NSDraggingItem(pasteboardWriter: url as NSURL)
        let icon = thumbnail ?? NSWorkspace.shared.icon(forFile: url.path)
        icon.size = NSSize(width: 48, height: 48)
        item.setDraggingFrame(NSRect(x: 0, y: 0, width: 48, height: 48), contents: icon)

        beginDraggingSession(with: [item], event: event, source: self)
    }
}
