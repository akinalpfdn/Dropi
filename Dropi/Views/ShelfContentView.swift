import SwiftUI
import UniformTypeIdentifiers

struct ShelfContentView: View {
    @StateObject private var viewModel = ShelfViewModel()
    @State private var isDropTargeted = false

    private let columns = [
        GridItem(.adaptive(minimum: Constants.Shelf.itemSize + 20), spacing: Constants.Shelf.itemSpacing)
    ]

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            if viewModel.items.isEmpty {
                DropZoneView()
            } else {
                itemsGrid
                footerBar
            }
        }
        .frame(
            minWidth: Constants.Shelf.defaultWidth,
            maxWidth: Constants.Shelf.maxWidth
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Shelf.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Shelf.cornerRadius)
                .strokeBorder(isDropTargeted ? Color.accentColor.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDrop(providers: providers)
        }
    }

    private var dragHandle: some View {
        HStack {
            Button {
                NSApp.windows.first(where: { $0 is ShelfWindow })?.orderOut(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            RoundedRectangle(cornerRadius: 2)
                .fill(.quaternary)
                .frame(width: 36, height: 4)

            Spacer()

            Button {
                viewModel.clearAll()
                NSApp.windows.first(where: { $0 is ShelfWindow })?.orderOut(nil)
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 14))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(WindowDragGesture())
    }

    private var itemsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Constants.Shelf.itemSpacing) {
                ForEach(viewModel.items) { item in
                    ShelfItemView(
                        item: item,
                        onRemove: { viewModel.remove(item) }
                    )
                }
            }
            .padding(.horizontal, Constants.Shelf.padding)
            .padding(.vertical, 8)
        }
        .frame(maxHeight: Constants.Shelf.maxHeight - 80)
    }

    private var footerBar: some View {
        HStack {
            Text("\(viewModel.items.count) item\(viewModel.items.count == 1 ? "" : "s")")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
            Spacer()
            Button("Clear All") {
                viewModel.clearAll()
            }
            .font(.system(size: 11))
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.vertical, 8)
    }
}

struct WindowDragGesture: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowDragView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private class WindowDragView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
