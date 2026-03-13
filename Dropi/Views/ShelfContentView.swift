import SwiftUI
import UniformTypeIdentifiers

struct ShelfContentView: View {
    @StateObject private var viewModel = ShelfViewModel()
    @StateObject private var settings = AppSettings.shared
    @State private var isDropTargeted = false
    @State private var isExpanded = false
    @State private var showSettings = false

    private let expandedColumns = [
        GridItem(.fixed(Constants.Shelf.itemSize + 12)),
        GridItem(.fixed(Constants.Shelf.itemSize + 12)),
        GridItem(.fixed(Constants.Shelf.itemSize + 12))
    ]

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            if showSettings {
                SettingsView(settings: settings)
            } else if viewModel.items.isEmpty {
                DropZoneView()
                    .frame(width: Constants.Shelf.compactWidth, height: 200)
            } else if isExpanded {
                expandedView
            } else {
                CompactShelfView(
                    items: viewModel.items,
                    onExpand: { expand() }
                )
                clearBar
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Shelf.cornerRadius))
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            viewModel.handleDrop(providers: providers)
        }
        .onChange(of: viewModel.items.count) {
            if viewModel.items.isEmpty && isExpanded {
                collapse()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeSettings)) { _ in
            withAnimation(.spring(duration: 0.25)) { showSettings = false }
        }
    }

    private func expand() {
        withAnimation(.spring(duration: 0.3)) { isExpanded = true }
        resizeWindow(width: Constants.Shelf.expandedWidth, height: Constants.Shelf.expandedHeight)
    }

    private func collapse() {
        withAnimation(.spring(duration: 0.3)) { isExpanded = false }
        resizeWindow(width: Constants.Shelf.compactWidth, height: Constants.Shelf.compactHeight)
    }

    private func resizeWindow(width: CGFloat, height: CGFloat) {
        guard let window = NSApp.windows.first(where: { $0 is ShelfWindow }) else { return }
        let oldFrame = window.frame
        let newFrame = NSRect(
            x: oldFrame.midX - width / 2,
            y: oldFrame.midY - height / 2,
            width: width,
            height: height
        )
        window.animator().setFrame(newFrame, display: true)
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        HStack {
            Button {
                NSApp.windows.first(where: { $0 is ShelfWindow })?.orderOut(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white.opacity(0.8), .white.opacity(0.15))
            }
            .buttonStyle(.plain)

            Spacer()

            RoundedRectangle(cornerRadius: 2.5)
                .fill(.quaternary)
                .frame(width: 40, height: 5)

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.25)) {
                    showSettings.toggle()
                    if showSettings {
                        isExpanded = false
                    }
                }
            } label: {
                Image(systemName: showSettings ? "gearshape.circle.fill" : "gearshape.circle")
                    .font(.system(size: 20))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(
                        showSettings ? .white : .white.opacity(0.8),
                        showSettings ? Color.accentColor.opacity(0.6) : .white.opacity(0.15)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Shelf.padding + 2)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(WindowDragGesture())
    }

    // MARK: - Expanded View

    private var expandedView: some View {
        VStack(spacing: 0) {
            expandedHeader

            ScrollView {
                LazyVGrid(columns: expandedColumns, spacing: Constants.Shelf.itemSpacing) {
                    ForEach(viewModel.items) { item in
                        ShelfItemView(
                            item: item,
                            onRemove: { viewModel.remove(item) }
                        )
                    }
                }
                .padding(.horizontal, Constants.Shelf.padding)
                .padding(.vertical, 8)
            }

            footerBar
        }
        .frame(width: Constants.Shelf.expandedWidth)
    }

    private var expandedHeader: some View {
        HStack(spacing: 8) {
            Button {
                collapse()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 16))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text("\(viewModel.items.count) Files")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.vertical, 8)
    }

    private var clearBar: some View {
        HStack {
            Button {
                viewModel.clearAll()
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 26))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.bottom, 8)
    }

    private var footerBar: some View {
        HStack {
            Spacer()
            Button("Clear All") {
                viewModel.clearAll()
            }
            .font(.system(size: 11, weight: .medium))
            .buttonStyle(.plain)
            .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Window Drag Helper

struct WindowDragGesture: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { WindowDragView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

private class WindowDragView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}
