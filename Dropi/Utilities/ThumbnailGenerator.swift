import AppKit
import QuickLookUI

struct ThumbnailGenerator {
    static func generate(for url: URL, size: CGSize = Constants.Thumbnail.size) async -> NSImage {
        let scale = await MainActor.run { NSScreen.main?.backingScaleFactor ?? 2.0 }
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )

        if let thumbnail = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: request) {
            return thumbnail.nsImage
        }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}
