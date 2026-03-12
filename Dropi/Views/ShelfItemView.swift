import SwiftUI

struct ShelfItemView: View {
    let item: ShelfItem
    let onRemove: () -> Void
    let onDragEnded: (ShelfItem) -> Void

    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                thumbnailView
                    .frame(width: Constants.Shelf.itemSize, height: Constants.Shelf.itemSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(item.fileName)
                    .font(.system(size: 10))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .frame(width: Constants.Shelf.itemSize)
            }
            .padding(4)
            .background(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                DraggableFile(item: item, onDragEnded: onDragEnded)
                    .opacity(0)
            )

            if isHovered {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .offset(x: 2, y: -2)
            }
        }
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let image = item.thumbnail {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(nsImage: NSWorkspace.shared.icon(forFile: item.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay {
                    ProgressView().scaleEffect(0.5)
                }
        }
    }
}
