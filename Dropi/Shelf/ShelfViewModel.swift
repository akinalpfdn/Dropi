import AppKit
import Combine
import UniformTypeIdentifiers

@MainActor
class ShelfViewModel: ObservableObject {
    @Published var items: [ShelfItem] = []

    private let store = ShelfStore.shared

    init() {
        store.$items
            .assign(to: &$items)
    }

    func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { [weak self] item, _ in
                    let url: URL? = {
                        if let data = item as? Data {
                            return URL(dataRepresentation: data, relativeTo: nil)
                        } else if let url = item as? URL {
                            return url
                        } else if let string = item as? String {
                            return URL(string: string)
                        }
                        return nil
                    }()
                    guard let url, let viewModel = self else { return }
                    Task { @MainActor in viewModel.addFile(url: url) }
                }
                handled = true
            }
        }
        return handled
    }

    func addFile(url: URL) {
        let item = ShelfItem(url: url)
        store.add(item)
        let itemID = item.id
        Task.detached(priority: .userInitiated) {
            let image = await ThumbnailGenerator.generate(for: url)
            await MainActor.run { [weak self] in
                self?.store.updateThumbnail(id: itemID, image: image)
            }
        }
    }

    func remove(_ item: ShelfItem) {
        store.remove(item)
    }

    func removeByURLs(_ urls: [URL]) {
        for url in urls {
            store.removeByURL(url)
        }
    }

    func clearAll() {
        store.clearAll()
    }
}
