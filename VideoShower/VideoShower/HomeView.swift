import SwiftUI

struct HomeView: View {
    
    
    @ObservedObject var mediaManager = MediaManager.shared
    @State private var selectedMediaIndex: Int = 0
    @State private var isFullScreenPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Your Uploads")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                if mediaManager.mediaURLs.isEmpty {
                    Text("No media uploaded yet!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    VStack {
                        Image(uiImage: UIImage(contentsOfFile: mediaManager.mediaURLs[selectedMediaIndex].path) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding()
                            .onTapGesture {
                                isFullScreenPresented = true // ✅ Open full-screen view
                            }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(mediaManager.mediaURLs.indices, id: \.self) { index in
                                    Image(uiImage: UIImage(contentsOfFile: mediaManager.mediaURLs[index].path) ?? UIImage())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(4)
                                        .onTapGesture {
                                            selectedMediaIndex = index
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .navigationTitle("Home")
            .fullScreenCover(isPresented: $isFullScreenPresented) {
                FullScreenMediaView(selectedIndex: $selectedMediaIndex, mediaURLs: mediaManager.mediaURLs)
            }
            .onAppear {
                mediaManager.loadStoredMedia()
            }
        }
    }
}

#Preview {
    HomeView()
}
