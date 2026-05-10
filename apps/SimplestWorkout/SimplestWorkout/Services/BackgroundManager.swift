import SwiftUI
import PhotosUI

@Observable
final class BackgroundManager {
    static let shared = BackgroundManager()

    var image: UIImage?

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appending(path: "background.jpg")
    }()

    private init() {
        loadImage()
    }

    var hasBackground: Bool { image != nil }

    func save(_ uiImage: UIImage) {
        image = uiImage
        if let data = uiImage.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }

    func remove() {
        image = nil
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func loadImage() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = UIImage(data: data) else { return }
        image = loaded
    }
}

struct CustomBackground: ViewModifier {
    @Environment(BackgroundManager.self) private var backgroundManager

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                if let image = backgroundManager.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .overlay(Color(.systemBackground).opacity(0.75))
                }
            }
    }
}

extension View {
    func customBackground() -> some View {
        modifier(CustomBackground())
    }
}
