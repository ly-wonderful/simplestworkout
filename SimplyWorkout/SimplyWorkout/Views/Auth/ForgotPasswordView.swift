import SwiftUI

struct ForgotPasswordView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var sent = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if sent {
                    Image(systemName: "envelope.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("Reset link sent")
                        .font(.title2.bold())
                    Text("Check your email for a link to reset your password.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Reset your password")
                        .font(.title2.bold())
                    Text("Enter your email and we'll send you a reset link.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    Button {
                        Task {
                            await authViewModel.sendPasswordReset(email: email)
                            if authViewModel.errorMessage == nil { sent = true }
                        }
                    } label: {
                        Group {
                            if authViewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Send Reset Link").frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
