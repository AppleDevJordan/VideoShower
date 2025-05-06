//
//  MediaPreviewView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//

import SwiftUI
import AVKit

struct MediaPreviewView: View {
    @ObservedObject var mediaStorage = MediaStorage.shared // ✅ Updated reference

    var body: some View {
        VStack {
            Text("Uploaded Media")
                .font(.title)
                .padding()

            if mediaStorage.mediaURLs.isEmpty {
                Text("No media available.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(mediaStorage.mediaURLs, id: \.self) { mediaURL in
                            mediaItemView(for: mediaURL) // ✅ Extracted for readability
                        }
                    }
                    .padding()
                }
            }
        }
    }

    // ✅ Displays Image or Video Based on File Type
    @ViewBuilder
    private func mediaItemView(for mediaURL: URL) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 300)

            if mediaURL.pathExtension == "jpg" || mediaURL.pathExtension == "png" {
                Image(uiImage: UIImage(contentsOfFile: mediaURL.path) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if mediaURL.pathExtension == "mp4" || mediaURL.pathExtension == "mov" {
                VideoPlayer(player: AVPlayer(url: mediaURL))
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    MediaPreviewView()
}
