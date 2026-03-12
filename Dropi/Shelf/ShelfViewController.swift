import AppKit
import SwiftUI

final class ShelfViewController: NSHostingController<ShelfContentView> {
    init() {
        super.init(rootView: ShelfContentView())
    }

    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
