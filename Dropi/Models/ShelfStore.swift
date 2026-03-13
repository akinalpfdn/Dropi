import AppKit
import Combine

@MainActor
class ShelfStore: ObservableObject {
    static let shared = ShelfStore()

    @Published var items: [ShelfItem] = []

    private init() {}

    func add(_ item: ShelfItem) {
        guard !items.contains(where: { $0.url == item.url }) else { return }
        items.append(item)
    }

    func remove(_ item: ShelfItem) {
        items.removeAll { $0.id == item.id }
    }

    func removeByURL(_ url: URL) {
        items.removeAll { $0.url == url }
    }

    func updateThumbnail(id: UUID, image: NSImage) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].thumbnail = image
    }

    func clearAll() {
        items.removeAll()
    }
}
