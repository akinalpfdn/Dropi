import AppKit
import SwiftUI

struct MultiFileDragSource: NSViewRepresentable {
    let urls: [URL]
    var onDragCompleted: (([URL]) -> Void)?

    func makeNSView(context: Context) -> MultiFileDragNSView {
        MultiFileDragNSView()
    }

    func updateNSView(_ nsView: MultiFileDragNSView, context: Context) {
        nsView.urls = urls
        nsView.onDragCompleted = onDragCompleted
    }
}

final class MultiFileDragNSView: NSView, NSDraggingSource {
    var urls: [URL] = []
    var onDragCompleted: (([URL]) -> Void)?

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
        guard !urls.isEmpty else {
            super.mouseDown(with: event)
            return
        }

        let draggingItems = urls.map { url -> NSDraggingItem in
            let item = NSDraggingItem(pasteboardWriter: url as NSURL)
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = NSSize(width: 48, height: 48)
            item.setDraggingFrame(NSRect(x: 0, y: 0, width: 48, height: 48), contents: icon)
            return item
        }

        beginDraggingSession(with: draggingItems, event: event, source: self)
    }
}
