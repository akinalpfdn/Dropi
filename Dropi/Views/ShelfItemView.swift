import SwiftUI
import AppKit

struct ShelfItemView: View {
    let item: ShelfItem
    let onRemove: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                thumbnailView
                    .frame(width: Constants.Shelf.itemSize, height: Constants.Shelf.itemSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)

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
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onDrag {
            NSItemProvider(object: item.url as NSURL)
        }
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
