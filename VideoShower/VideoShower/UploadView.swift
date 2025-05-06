import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers

struct UploadView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uploadProgress: Double = 0.0
    @ObservedObject var mediaStorage = MediaStorage.shared

    var savedUsername: String {
        UserDefaults.standard.string(forKey: "username") ?? "Guest"
    }

    var body: some View {
        VStack(spacing: 20) {
            userProfileSection()
            filePickerSection()
            uploadProgressBar()
            uploadedImageSection() // ✅ Displays latest uploaded image in center
            publishButton()

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.white, Color.blue.opacity(0.2)]),
                           startPoint: .top,
                           endPoint: .bottom)
        )
    }
    
    // ✅ User Profile Section
    private func userProfileSection() -> some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
                .padding(.bottom, 5)

            Text("Welcome, \(savedUsername)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    // ✅ Upload Progress Bar
    private func uploadProgressBar() -> some View {
        if uploadProgress > 0 {
            ProgressView(value: uploadProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal) as! EmptyView
        } else {
            EmptyView()
        }
    }

    // ✅ Publish Button
    private func publishButton() -> some View {
        Button {
            publishSelectedFiles()
        } label: {
            Label("Publish", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
        }
    }


    // ✅ Uploaded Image (Centered)
    private func uploadedImageSection() -> some View {
        VStack {
            if let latestFileURL = mediaStorage.mediaURLs.last,
               latestFileURL.pathExtension.lowercased() == "jpg" {
                Image(uiImage: UIImage(contentsOfFile: latestFileURL.path) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // ✅ Centered image size
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
            } else {
                Text("No image uploaded yet.")
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // ✅ File Picker Section
    private func filePickerSection() -> some View {
        PhotosPicker(selection: $selectedItems, matching: .any(of: [.images])) { // ✅ Ensures only images are selected
            Label("Choose Image", systemImage: "photo.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
        }
        .padding()
    }

    // ✅ File Upload Logic
    private func publishSelectedFiles() {
        Task {
            if let newItem = selectedItems.last {
                let fileName = "media_\(UUID().uuidString).jpg"
                
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    mediaStorage.saveFile(data: data, fileName: fileName, uploadedBy: savedUsername)
                }
            }
        }
    }
}

#Preview {
    UploadView()
}
