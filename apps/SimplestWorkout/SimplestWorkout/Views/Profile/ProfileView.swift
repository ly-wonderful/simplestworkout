import SwiftUI

struct ProfileView: View {
    @AppStorage("weightUnit") private var weightUnit = "lbs"

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

                Section("App") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Profile")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
