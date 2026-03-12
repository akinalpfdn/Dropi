import AppKit
import Combine

@MainActor
class ShelfViewModel: ObservableObject {
    @Published var items: [ShelfItem] = []

    private let store = ShelfStore.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        store.$items
            .assign(to: &$items)
    }

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { [weak self] url, _ in
                    guard let url else { return }
                    Task { @MainActor in self?.addFile(url: url) }
                }
                handled = true
            }
        }
        return handled
    }

    func addFile(url: URL) {
        let item = ShelfItem(url: url)
        store.add(item)
        Task.detached(priority: .userInitiated) {
            let image = await ThumbnailGenerator.generate(for: url)
            await MainActor.run { self.store.updateThumbnail(id: item.id, image: image) }
        }
    }

    func remove(_ item: ShelfItem) {
        store.remove(item)
    }

    func clearAll() {
        store.clearAll()
    }
}
