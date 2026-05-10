import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(BackgroundManager.self) private var backgroundManager
    @AppStorage("weightUnit") private var weightUnit = "lbs"
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("lbs").tag("lbs")
                        Text("kg").tag("kg")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Background") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(
                            backgroundManager.hasBackground ? "Change Background Photo" : "Set Background Photo",
                            systemImage: "photo"
                        )
                    }

                    if backgroundManager.hasBackground {
                        Button("Remove Background", role: .destructive) {
                            backgroundManager.remove()
                        }
                    }
                }

                Section("App") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .customBackground()
            .navigationTitle("Profile")
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    guard let newItem,
                          let data = try? await newItem.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    backgroundManager.save(uiImage)
                    selectedPhoto = nil
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
