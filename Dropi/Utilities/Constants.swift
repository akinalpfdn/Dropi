import CoreGraphics

enum Constants {
    enum Shelf {
        static let defaultWidth: CGFloat = 280
        static let defaultHeight: CGFloat = 320
        static let maxWidth: CGFloat = 400
        static let maxHeight: CGFloat = 600
        static let cornerRadius: CGFloat = 12
        static let itemSize: CGFloat = 72
        static let itemSpacing: CGFloat = 8
        static let padding: CGFloat = 10
    }

    enum Thumbnail {
        static let size = CGSize(width: 64, height: 64)
        static let timeout: TimeInterval = 2.0
    }
}
