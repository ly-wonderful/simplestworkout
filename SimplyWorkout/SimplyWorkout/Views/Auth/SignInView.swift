import SwiftUI

struct SignInView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("SimplyWorkout")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task { await authViewModel.signIn(email: email, password: password) }
            } label: {
                Group {
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In").frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

            Button("Forgot Password?") { showForgotPassword = true }
                .font(.footnote)

            Spacer()

            NavigationLink("Create an account") { SignUpView() }
                .padding(.bottom)
        }
        .padding()
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}
