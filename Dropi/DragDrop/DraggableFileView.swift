import AppKit
import SwiftUI

final class DraggableFileNSView: NSView, NSDraggingSource {
    var item: ShelfItem?
    var onDragEnded: ((ShelfItem) -> Void)?

    override func mouseDown(with event: NSEvent) {
        guard let item else { return }

        let pbItem = NSPasteboardItem()
        pbItem.setString(item.url.absoluteString, forType: .fileURL)

        let draggingItem = NSDraggingItem(pasteboardWriter: pbItem)
        let image = item.thumbnail ?? NSWorkspace.shared.icon(forFile: item.url.path)
        draggingItem.setDraggingFrame(bounds, contents: image)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

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
        guard let item, operation != [] else { return }
        onDragEnded?(item)
    }
}

struct DraggableFile: NSViewRepresentable {
    let item: ShelfItem
    let onDragEnded: (ShelfItem) -> Void

    func makeNSView(context: Context) -> DraggableFileNSView {
        let view = DraggableFileNSView()
        view.item = item
        view.onDragEnded = onDragEnded
        return view
    }

    func updateNSView(_ nsView: DraggableFileNSView, context: Context) {
        nsView.item = item
        nsView.onDragEnded = onDragEnded
    }
}
