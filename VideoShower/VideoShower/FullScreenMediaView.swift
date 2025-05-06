import SwiftUI

struct FullScreenMediaView: View {
    @Binding var selectedIndex: Int
    var mediaURLs: [URL]
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                TabView(selection: $selectedIndex) {
                    ForEach(mediaURLs.indices, id: \.self) { index in
                        Image(uiImage: UIImage(contentsOfFile: mediaURLs[index].path) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(dragOffset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(1.0, value.magnitude)
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation
                                    }
                                    .onEnded { value in
                                        if value.translation.height > 100 {
                                            presentationMode.wrappedValue.dismiss() // ✅ Swipe down to dismiss
                                        }
                                        dragOffset = .zero
                                    }
                            )
                            .tag(index)
                            .transition(.opacity)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .animation(.easeInOut, value: selectedIndex)

            // ✅ Close Button Overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FullScreenMediaView(selectedIndex: .constant(0), mediaURLs: [])
}
