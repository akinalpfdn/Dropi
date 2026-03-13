import AppKit
import SwiftUI

struct MultiFileDragSource: NSViewRepresentable {
    let urls: [URL]

    func makeNSView(context: Context) -> MultiFileDragNSView {
        MultiFileDragNSView()
    }

    func updateNSView(_ nsView: MultiFileDragNSView, context: Context) {
        nsView.urls = urls
    }
}

final class MultiFileDragNSView: NSView, NSDraggingSource {
    var urls: [URL] = []

    func draggingSession(
        _ session: NSDraggingSession,
        sourceOperationMaskFor context: NSDraggingContext
    ) -> NSDragOperation {
        context == .outsideApplication ? [.copy, .move] : .move
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
