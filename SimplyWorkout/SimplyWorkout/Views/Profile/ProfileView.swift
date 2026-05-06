import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showSignOutAlert = false
    @AppStorage("exerciseDBApiKey") private var exerciseDBApiKey = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Email", value: authViewModel.currentUserEmail)
                }

                Section {
                    LabeledContent("ExerciseDB Key") {
                        SecureField("RapidAPI key", text: $exerciseDBApiKey)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("API Keys")
                } footer: {
                    Text("Required to browse exercises from ExerciseDB when creating plans.")
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        showSignOutAlert = true
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) { authViewModel.signOut() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
