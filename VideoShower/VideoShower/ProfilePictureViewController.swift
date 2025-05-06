//
//  ProfilePictureViewController.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/2/25.
//


import UIKit
import Photos

class ProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPhotoLibraryPermission()
    }

    // ✅ Ensure Permission Check for Photo Library
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { _ in }
        }
    }

    // ✅ Select Image from Gallery
    @IBAction func selectImageFromGallery(_ sender: UIButton) {
        presentImagePicker(sourceType: .photoLibrary)
    }
    
    // ✅ Take Photo Using Camera
    @IBAction func takePhoto(_ sender: UIButton) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        if cameraStatus == .denied || cameraStatus == .restricted {
            showAlert(title: "Camera Access Denied", message: "Please enable camera access in settings.")
            return
        }
        
        presentImagePicker(sourceType: .camera)
    }

    // ✅ Present UIImagePickerController
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "Error", message: "Source type not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true)
    }
    
    // ✅ Handle Image Selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            saveImageToUserDefaults(selectedImage)
        }
        picker.dismiss(animated: true)
    }

    // ✅ Save Image to UserDefaults for Future Use
    private func saveImageToUserDefaults(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profilePicture")
        }
    }
    
    // ✅ Handle Cancel Action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // ✅ Display Alert Messages
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
