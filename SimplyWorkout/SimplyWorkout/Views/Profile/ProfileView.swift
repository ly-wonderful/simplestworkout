import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent("Email", value: authViewModel.currentUserEmail)
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
