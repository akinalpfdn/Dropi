import SwiftUI
import AppKit

struct CompactShelfView: View {
    let items: [ShelfItem]
    let onExpand: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ForEach(Array(stackItems.enumerated()), id: \.element.id) { index, item in
                    thumbnailCard(for: item)
                        .rotationEffect(.degrees(rotationFor(index: index)))
                        .scaleEffect(scaleFor(index: index))
                }
            }
            .frame(width: 150, height: 150)
            .overlay(MultiFileDragSource(urls: items.map(\.url)))

            Button(action: onExpand) {
                HStack(spacing: 4) {
                    Text("\(items.count) File\(items.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var stackItems: [ShelfItem] {
        Array(items.suffix(3).reversed())
    }

    private func rotationFor(index: Int) -> Double {
        let count = stackItems.count
        guard count > 1 else { return 0 }
        let mid = Double(count - 1) / 2.0
        return (Double(index) - mid) * 4
    }

    private func scaleFor(index: Int) -> Double {
        let count = stackItems.count
        guard count > 1 else { return 1 }
        return 1.0 - Double(count - 1 - index) * 0.04
    }

    private func thumbnailCard(for item: ShelfItem) -> some View {
        Group {
            if let thumb = item.thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Color(nsColor: .controlBackgroundColor)
                    Image(nsImage: NSWorkspace.shared.icon(forFile: item.url.path))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                }
            }
        }
        .frame(width: 130, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }
}
