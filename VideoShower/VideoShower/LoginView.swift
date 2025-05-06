import SwiftUI
import CryptoKit // ✅ Required for password hashing

struct LoginView: View {
    @ObservedObject var authManager: AuthManager // ✅ Authentication state management

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var navigateToContentView: Bool = false // ✅ Triggers navigation

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    handleLogin()
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()

                HStack {
                    NavigationLink("Register", destination: RegistrationView())
                    Spacer()
                    NavigationLink("Forgot Password?", destination: Text("Password Reset Page"))
                }
                .padding(.horizontal)
                .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text("Invalid credentials. Please try again."), dismissButton: .default(Text("OK")))
            }
            .fullScreenCover(isPresented: $navigateToContentView) { // ✅ Routes to ContentView when login is successful
                ContentView()
            }
        }
    }

    private func handleLogin() {
        let storedUsername = UserDefaults.standard.string(forKey: "username") ?? ""
        let storedPassword = UserDefaults.standard.string(forKey: "password") ?? ""
        let hashedInputPassword = hashPassword(password) // ✅ Properly defined before comparison

        if username == storedUsername && hashedInputPassword == storedPassword {
            navigateToContentView = true // ✅ Triggers navigation when login is successful
        } else {
            showAlert = true
        }
    }
}

// ✅ Secure password hashing function (moved outside `handleLogin()`)
func hashPassword(_ password: String) -> String {
    let data = Data(password.utf8)
    let hashed = SHA256.hash(data: data)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

#Preview {
    LoginView(authManager: AuthManager())
}
