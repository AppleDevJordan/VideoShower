//
//  RegistrationView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/2/25.
//

import SwiftUI
import CryptoKit // ✅ Required for password hashing


struct RegistrationView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var passwordStrengthMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode // ✅ For dismissing view

    var body: some View {
        NavigationView {
            VStack {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.username) // ✅ Autofill support
                    .padding()

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress) // ✅ Autofill support
                    .padding()

                TextField("Phone Number (Optional)", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.telephoneNumber) // ✅ Autofill support
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword) // ✅ Autofill support
                    .padding()
                    .onChange(of: password) { newValue in
                        passwordStrengthMessage = validatePassword(newValue) // ✅ Live feedback
                    }

                ProgressView(value: Double(password.count), total: 12) // ✅ Password strength bar
                    .progressViewStyle(LinearProgressViewStyle())
                    .foregroundColor(passwordStrengthColor)
                    .padding()

                Text(passwordStrengthMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)

                SecureField("Confirm Password", text: $confirmPassword) // ✅ Added confirmation field
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                        alertMessage = "Ensure all fields are filled."
                        showAlert = true
                    } else if !isPasswordStrong(password) {
                        alertMessage = "Password is too weak."
                        showAlert = true
                    } else if password != confirmPassword {
                        alertMessage = "Passwords do not match."
                        showAlert = true
                    } else {
                        let hashedPassword = hashPassword(password) // ✅ Securely hash the password
                        saveUserData(username: username, email: email, phoneNumber: phoneNumber, password: hashedPassword)
                        presentationMode.wrappedValue.dismiss() // ✅ Exit registration
                    }
                }) {
                    Text("Save & Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // ✅ Password validation function
    func validatePassword(_ password: String) -> String {
        if password.count < 8 {
            return "❌ Password must be at least 8 characters."
        } else if !password.contains(where: { $0.isUppercase }) {
            return "❌ Password must contain at least one uppercase letter."
        } else if !password.contains(where: { $0.isLowercase }) {
            return "❌ Password must contain at least one lowercase letter."
        } else if !password.contains(where: { $0.isNumber }) {
            return "❌ Password must contain at least one number."
        } else if !password.contains(where: { "!@#$%^&*()".contains($0) }) {
            return "❌ Password must contain at least one special character."
        } else {
            return "✅ Password is strong!"
        }
    }
    
    func isPasswordStrong(_ password: String) -> Bool {
        return password.count >= 8 &&
               password.contains(where: { $0.isUppercase }) &&
               password.contains(where: { $0.isLowercase }) &&
               password.contains(where: { $0.isNumber }) &&
               password.contains(where: { "!@#$%^&*()".contains($0) })
    }


    var passwordStrengthColor: Color {
        if password.count < 8 { return .red }
        else if password.contains(where: { $0.isUppercase }) &&
                password.contains(where: { $0.isNumber }) &&
                password.contains(where: { "!@#$%^&*()".contains($0) }) {
            return .green
        } else {
            return .yellow
        }
    }

    // ✅ Secure password hashing using SHA256
    func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    // ✅ Local storage for user data using UserDefaults
    func saveUserData(username: String, email: String, phoneNumber: String, password: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.set(password, forKey: "password") // ✅ Stores hashed password
    }
}

#Preview {
    RegistrationView()
}
