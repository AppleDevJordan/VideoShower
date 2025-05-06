import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }

    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
    }

    func login(username: String, password: String) -> Bool { // ✅ Returns Bool value
        if username == "user" && password == "password" { // Replace with actual validation logic
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
            return true // ✅ Successfully authenticated
        }
        return false // ✅ Authentication failed
    }

    func logout() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}

