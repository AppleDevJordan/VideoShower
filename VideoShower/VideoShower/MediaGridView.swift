//
//  MediaGridView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//
import SwiftUI

// ✅ Identifiable struct for user profiles

struct MediaGridView: View {
    @ObservedObject var mediaStorage = MediaStorage.shared

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(mediaStorage.mediaURLs.indices, id: \.self) { index in
                        mediaItemView(index: index) // ✅ Extracted for clarity
                    }
                }
                .padding()
            }
            .navigationTitle("Published Uploads")
        }
    }

    @ViewBuilder
    private func mediaItemView(index: Int) -> some View {
        let fileURL = mediaStorage.mediaURLs[index]
        let uploader = mediaStorage.mediaMetadata[fileURL.absoluteString]?["uploadedBy"] as? String ?? "Unknown"

        VStack {
            Image(uiImage: UIImage(contentsOfFile: fileURL.path) ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            
            Text(mediaStorage.getFileHash(for: fileURL) ?? "#NoTag")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.bottom, 5)

            Text("Uploaded by: \(uploader)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


#Preview {
    MediaGridView()
}
