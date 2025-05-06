import SwiftUI
import CryptoKit

class MediaStorage: ObservableObject {
    @Published var mediaURLs: [URL] = []
    @Published var mediaMetadata: [String: [String: Any]] = [:]

    static let shared = MediaStorage()

    init() {
        DispatchQueue.global(qos: .utility).async {
            self.loadStoredMedia()
            self.loadMetadata()
            self.cleanInvalidFiles()
        }
    }

    // ✅ Loads previously stored media URLs
    func loadStoredMedia() {
        guard let paths = UserDefaults.standard.stringArray(forKey: "savedMediaURLs") else { return }
        DispatchQueue.main.async {
            self.mediaURLs = paths.compactMap { URL(string: $0) }
        }
    }

    // ✅ Cleans up invalid file references
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

    // ✅ Saves a new file and updates metadata
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

    // ✅ Persists media URLs in UserDefaults
    private func persistMediaURLs() {
        let paths = mediaURLs.map { $0.absoluteString }
        UserDefaults.standard.set(paths, forKey: "savedMediaURLs")
    }

    // ✅ Saves metadata for a given file
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

    // ✅ Retrieves stored metadata
    func loadMetadata() {
        guard let metadata = UserDefaults.standard.dictionary(forKey: "savedMediaMetadata") as? [String: [String: Any]] else { return }
        DispatchQueue.main.async {
            self.mediaMetadata = metadata
        }
    }

    // ✅ Generates SHA256 hash for a file
    func generateFileHash(data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    // ✅ Retrieves a file hash
    func getFileHash(for fileURL: URL) -> String? {
        return mediaMetadata[fileURL.absoluteString]?["hashTag"] as? String
    }

    // ✅ Updates the hash for a file
    func updateFileHash(for fileURL: URL, newHash: String) {
        DispatchQueue.main.async {
            self.mediaMetadata[fileURL.absoluteString]?["hashTag"] = "#\(newHash)"
            self.persistMetadata()
        }
    }

    // ✅ Persists metadata to UserDefaults
    private func persistMetadata() {
        UserDefaults.standard.set(mediaMetadata, forKey: "savedMediaMetadata")
    }

    // ✅ Deletes a file safely
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

    // ✅ Renames a file safely
    func renameFile(at index: Int, newName: String) {
        let fileManager = FileManager.default
        guard index >= 0, index < mediaURLs.count else { return }
        let oldFileURL = mediaURLs[index]
        let directory = oldFileURL.deletingLastPathComponent()

        let fileExtension = oldFileURL.pathExtension
        var finalName = newName
        if !fileExtension.isEmpty && !newName.lowercased().hasSuffix(fileExtension.lowercased()) {
            finalName.append(".\(fileExtension)")
        }
        let newFileURL = directory.appendingPathComponent(finalName)

        do {
            try fileManager.moveItem(at: oldFileURL, to: newFileURL)
            DispatchQueue.main.async {
                self.mediaURLs[index] = newFileURL
                self.mediaMetadata.removeValue(forKey: oldFileURL.absoluteString)
                self.saveMetadata(for: newFileURL, hashTag: "", uploadedBy: "")
                self.persistMediaURLs()
            }
            print("✅ Renamed file to: \(newFileURL)")
        } catch {
            print("❌ Error renaming file: \(error.localizedDescription)")
        }
    }
}
