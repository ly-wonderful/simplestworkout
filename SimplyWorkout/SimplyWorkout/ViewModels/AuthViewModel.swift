import Foundation
import Observation
import FirebaseAuth

@Observable
@MainActor
final class AuthViewModel {
    var isAuthenticated: Bool = false
    var currentUserId: String = ""
    var currentUserEmail: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let authService = AuthService.shared
    nonisolated(unsafe) private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenerHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isAuthenticated = user != nil
                self.currentUserId = user?.uid ?? ""
                self.currentUserEmail = user?.email ?? ""
            }
        }
    }

    deinit {
        if let handle = listenerHandle {
            authService.removeAuthStateListener(handle)
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = authService.mapError(error)
        }
        isLoading = false
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            errorMessage = authService.mapError(error)
        }
        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Failed to sign out."
        }
    }

    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await authService.sendPasswordReset(email: email)
        } catch {
            errorMessage = authService.mapError(error)
        }
        isLoading = false
    }
}
