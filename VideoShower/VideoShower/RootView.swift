//
//  RootView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/5/25.
//
import  SwiftUI

// ✅ RootView Handles Authentication Flow
import SwiftUI

struct RootView: View {
    @ObservedObject var authManager: AuthManager

    var body: some View {
        if authManager.isAuthenticated {
            ContentView()
        } else {
            LoginView(authManager: authManager) // ✅ Passes AuthManager correctly
        }
    }
}
