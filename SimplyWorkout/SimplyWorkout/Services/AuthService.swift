import Foundation
import FirebaseAuth

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func addAuthStateListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in listener(user) }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func mapError(_ error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .wrongPassword:       return "Incorrect password."
        case .userNotFound:        return "No account found with this email."
        case .emailAlreadyInUse:   return "This email is already registered."
        case .weakPassword:        return "Password must be at least 6 characters."
        case .networkError:        return "Network error. Check your connection."
        case .invalidEmail:        return "Please enter a valid email address."
        default:                   return "Something went wrong. Please try again."
        }
    }
}
