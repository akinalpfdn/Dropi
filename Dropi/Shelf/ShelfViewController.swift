import AppKit
import SwiftUI

final class ShelfViewController: NSHostingController<ShelfContentView> {
    init() {
        super.init(rootView: ShelfContentView())
    }

    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        replaceViewWithFirstMouse()
    }

    private func replaceViewWithFirstMouse() {
        guard let hostingView = view.subviews.first else { return }
        let wrapper = FirstMouseView(frame: view.bounds)
        wrapper.autoresizingMask = [.width, .height]
        hostingView.removeFromSuperview()
        hostingView.frame = wrapper.bounds
        hostingView.autoresizingMask = [.width, .height]
        wrapper.addSubview(hostingView)
        view.addSubview(wrapper)
    }
}
