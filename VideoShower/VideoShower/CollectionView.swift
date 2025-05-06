//
//  CollectionView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//


import SwiftUI

struct CollectionView: View {
    @ObservedObject var mediaStorage = MediaStorage.shared // ✅ Updated reference

    let columns: [GridItem] = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(mediaStorage.mediaURLs, id: \.self) { mediaURL in
                        Image(uiImage: UIImage(contentsOfFile: mediaURL.path) ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("The Collection")
        }
    }
}

#Preview {
    CollectionView()
}
