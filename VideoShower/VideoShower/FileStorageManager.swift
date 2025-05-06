//
//  FileStorageManager.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//


import SwiftUI

struct FileStorageManager {
    static let shared = FileStorageManager()
    
    func saveFile(data: Data, fileName: String) -> URL? {
        let fileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("File saved at: \(fileURL)")
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}
