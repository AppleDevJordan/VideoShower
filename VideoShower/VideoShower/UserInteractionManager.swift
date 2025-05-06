import Foundation

class UserInteractionManager: ObservableObject {
    @Published var userInteractions: [String: Set<String>] = [:] // Tracks mutual engagements

    static let shared = UserInteractionManager()

    init() {
        loadStoredInteractions() // Load stored interactions on startup
    }

    // Loads previously stored interactions from UserDefaults
    func loadStoredInteractions() {
        if let storedData = UserDefaults.standard.dictionary(forKey: "userInteractions") as? [String: [String]] {
            self.userInteractions = storedData.mapValues { Set($0) }
        }
    }

    // Saves updated user interactions to UserDefaults
    private func persistUserInteractions() {
        let convertedData = userInteractions.mapValues { Array($0) }
        UserDefaults.standard.set(convertedData, forKey: "userInteractions")
    }

    // Registers a new interaction between users
    func registerInteraction(from user: String, with targetUser: String) {
        DispatchQueue.main.async {
            self.userInteractions[user, default: Set<String>()].insert(targetUser)
            self.userInteractions[targetUser, default: Set<String>()].insert(user)
            self.persistUserInteractions()
        }
    }

    // Checks if both users have mutually interacted and can message each other
    func canMessage(user: String, targetUser: String) -> Bool {
        guard let interactionsForUser = userInteractions[user],
              let interactionsForTarget = userInteractions[targetUser] else {
            return false
        }
        return interactionsForUser.contains(targetUser) && interactionsForTarget.contains(user)
    }
}
