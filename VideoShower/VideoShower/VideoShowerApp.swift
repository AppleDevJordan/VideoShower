//
//  VideoShowerApp.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//

import SwiftUI

@main
struct VideoShowerApp: App {
    @StateObject private var authManager = AuthManager() // ✅ Ensures `AuthManager` is created once

    var body: some Scene {
        WindowGroup {
            RootView(authManager: authManager) // ✅ Refactored main flow to a separate view
        }
    }
}

