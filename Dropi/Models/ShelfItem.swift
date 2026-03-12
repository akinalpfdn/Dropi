import AppKit
import UniformTypeIdentifiers

struct ShelfItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let fileName: String
    let fileType: UTType
    let fileSize: Int64
    var thumbnail: NSImage?
    let addedAt = Date()

    init(url: URL) {
        self.url = url
        self.fileName = url.lastPathComponent
        self.fileType = UTType(filenameExtension: url.pathExtension) ?? .data
        self.fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
    }

    static func == (lhs: ShelfItem, rhs: ShelfItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
