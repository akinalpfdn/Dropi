import AppKit
import QuickLookThumbnailing

struct ThumbnailGenerator {
    private static let size = CGSize(width: 120, height: 120)

    static func generate(for url: URL) async -> NSImage {
        let scale = await MainActor.run { NSScreen.main?.backingScaleFactor ?? 2.0 }

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )

        return await withCheckedContinuation { continuation in
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, _ in
                if let thumbnail {
                    continuation.resume(returning: thumbnail.nsImage)
                } else {
                    continuation.resume(returning: NSWorkspace.shared.icon(forFile: url.path))
                }
            }
        }
    }
}
