import SwiftUI

struct ShelfContentView: View {
    @StateObject private var viewModel = ShelfViewModel()
    @State private var isDropTargeted = false

    private let columns = [GridItem(.adaptive(minimum: Constants.Shelf.itemSize + 16), spacing: Constants.Shelf.itemSpacing)]

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            Divider()

            if viewModel.items.isEmpty {
                DropZoneView()
            } else {
                itemsGrid
                Divider()
                footerBar
            }
        }
        .frame(width: Constants.Shelf.defaultWidth)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Shelf.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Shelf.cornerRadius)
                .strokeBorder(isDropTargeted ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDrop(providers: providers)
        }
    }

    private var headerBar: some View {
        HStack {
            Image(systemName: "tray.and.arrow.down.fill")
                .foregroundStyle(.secondary)
            Text("Dropi")
                .font(.headline)
            Spacer()
            Button {
                NSApp.windows.first(where: { $0 is ShelfWindow })?.orderOut(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.vertical, 8)
    }

    private var itemsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Constants.Shelf.itemSpacing) {
                ForEach(viewModel.items) { item in
                    ShelfItemView(
                        item: item,
                        onRemove: { viewModel.remove(item) },
                        onDragEnded: { viewModel.remove($0) }
                    )
                }
            }
            .padding(Constants.Shelf.padding)
        }
        .frame(maxHeight: Constants.Shelf.maxHeight - 80)
    }

    private var footerBar: some View {
        HStack {
            Text("\(viewModel.items.count) item\(viewModel.items.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Clear All") {
                viewModel.clearAll()
            }
            .font(.caption)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.vertical, 6)
    }
}
