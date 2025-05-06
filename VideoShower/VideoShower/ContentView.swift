//
//  ContentView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/1/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to VideoShower!")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                // Navigation buttons
                NavigationLink("Go to Home", destination: HomeView())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                NavigationLink("Upload Media", destination: UploadView())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                // ✅ "The Collection" Button Moved Here
                NavigationLink("The Collection", destination: CollectionView())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }
}

#Preview {
    ContentView()
}
