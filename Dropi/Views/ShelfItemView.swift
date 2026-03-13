import SwiftUI
import AppKit

struct ShelfItemView: View {
    let item: ShelfItem
    let isSelected: Bool
    let onRemove: () -> Void
    let onTap: (Bool) -> Void
    let dragURLs: [URL]
    let onDragOut: (([URL]) -> Void)?

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                thumbnailView
                    .frame(width: Constants.Shelf.itemSize, height: Constants.Shelf.itemSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accentColor, lineWidth: isSelected ? 2.5 : 0)
                    )

                if isHovered {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .offset(x: 4, y: -4)
                    .transition(.opacity)
                }
            }

            Text(item.fileName)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    isSelected
                        ? AnyShapeStyle(Color.accentColor.opacity(0.3))
                        : AnyShapeStyle(.ultraThinMaterial),
                    in: Capsule()
                )
        }
        .padding(6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .overlay(MultiFileDragSource(
            urls: dragURLs,
            onDragCompleted: onDragOut,
            onTap: onTap
        ))
    }

    @ViewBuilder
    private var thumbnailView: some View {
        if let image = item.thumbnail {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Constants.Shelf.itemSize, height: Constants.Shelf.itemSize)
                .clipped()
        } else {
            ZStack {
                Color.gray.opacity(0.1)
                Image(nsImage: NSWorkspace.shared.icon(forFile: item.url.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
            }
        }
    }
}
