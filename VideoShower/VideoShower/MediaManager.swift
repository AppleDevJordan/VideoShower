import SwiftUI
import CryptoKit

class MediaManager: ObservableObject {
    @Published var mediaURLs: [URL] = []
    @Published var mediaMetadata: [String: [String: Any]] = [:]
    @Published var userInteractions: [String: Set<String>] = [:] // ✅ Tracks mutual interactions
    
    static let shared = MediaManager()
    
    init() {
        DispatchQueue.global(qos: .utility).async {
            self.loadStoredMedia()
            self.loadMetadata()
            self.cleanInvalidFiles()
            self.loadStoredInteractions() // ✅ Load interactions for messaging logic
        }
    }
    
    // MARK: - File & Metadata Handling
    
    func loadStoredInteractions() {
        if let storedData = UserDefaults.standard.dictionary(forKey: "userInteractions") as? [String: [String]] {
            DispatchQueue.main.async {
                self.userInteractions = storedData.mapValues { Set($0) }
            }
        }
    }

    func loadStoredMedia() {
        guard let paths = UserDefaults.standard.stringArray(forKey: "savedMediaURLs") else { return }
        DispatchQueue.main.async {
            self.mediaURLs = paths.compactMap { URL(string: $0) }
        }
    }

    func loadMetadata() {
        guard let metadata = UserDefaults.standard.dictionary(forKey: "savedMediaMetadata") as? [String: [String: Any]] else { return }
        DispatchQueue.main.async {
            self.mediaMetadata = metadata
        }
    }
    
    func cleanInvalidFiles() {
        let fileManager = FileManager.default
        DispatchQueue.global(qos: .utility).async {
            let validFiles = self.mediaURLs.filter { fileManager.fileExists(atPath: $0.path) }
            DispatchQueue.main.async {
                self.mediaURLs = validFiles
                self.persistMediaURLs()
            }
        }
    }
    
    // ✅ Define missing persist functions
    private func persistMediaURLs() {
        let paths = mediaURLs.map { $0.absoluteString }
        UserDefaults.standard.set(paths, forKey: "savedMediaURLs")
    }
    
    private func persistMetadata() {
        UserDefaults.standard.set(mediaMetadata, forKey: "savedMediaMetadata")
    }
    
    private func persistUserInteractions() {
        let convertedData = userInteractions.mapValues { Array($0) }
        UserDefaults.standard.set(convertedData, forKey: "userInteractions")
    }
    
    func saveFile(data: Data, fileName: String, uploadedBy: String) {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            let fileHash = generateFileHash(data: data)
            DispatchQueue.main.async {
                self.mediaURLs.append(fileURL)
                self.saveMetadata(for: fileURL, hashTag: fileHash, uploadedBy: uploadedBy)
                self.persistMediaURLs()
            }
            print("✅ File saved at: \(fileURL)")
        } catch {
            print("❌ Error saving file: \(error.localizedDescription)")
        }
    }
    
    fileprivate func saveMetadata(for fileURL: URL, hashTag: String, uploadedBy: String) {
        let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        let fileSize = attributes?[.size] as? Int64 ?? 0
        let creationDate = attributes?[.creationDate] as? Date ?? Date()
        
        DispatchQueue.main.async {
            self.mediaMetadata[fileURL.absoluteString] = [
                "fileName": fileURL.lastPathComponent,
                "size": "\(fileSize / 1024) KB",
                "date": creationDate.description,
                "hashTag": "#\(hashTag)",
                "uploadedBy": uploadedBy
            ]
            self.persistMetadata()
        }
    }
    
    // MARK: - Hashing & File Management
    
    func generateFileHash(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func getFileHash(for fileURL: URL) -> String? {
        return mediaMetadata[fileURL.absoluteString]?["hashTag"] as? String
    }
    
    func updateFileHash(for fileURL: URL, newHash: String) {
        DispatchQueue.main.async {
            self.mediaMetadata[fileURL.absoluteString]?["hashTag"] = "#\(newHash)"
            self.persistMetadata()
        }
    }
    
    func deleteFile(at index: Int) {
        let fileManager = FileManager.default
        guard index >= 0, index < mediaURLs.count else { return }
        let fileURL = mediaURLs[index]

        do {
            try fileManager.removeItem(at: fileURL)
            DispatchQueue.main.async {
                self.mediaURLs.remove(at: index)
                self.mediaMetadata.removeValue(forKey: fileURL.absoluteString)
                self.persistMediaURLs()
                self.persistMetadata()
            }
            print("✅ Deleted file: \(fileURL)")
        } catch {
            print("❌ Error deleting file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - User Interaction Handling
    
    func registerInteraction(from user: String, with targetUser: String) {
        DispatchQueue.main.async {
            self.userInteractions[user, default: Set<String>()].insert(targetUser)
            self.userInteractions[targetUser, default: Set<String>()].insert(user)
            self.persistUserInteractions()
        }
    }
}
