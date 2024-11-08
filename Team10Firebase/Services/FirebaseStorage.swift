//
//  FirebaseStorage.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/7/24.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseStorage: ObservableObject {
  @Published var image: UIImage?
  @Published var isLoading = false
  @Published var errorMessage: String?
  private let storage = Storage.storage()

  func uploadImageToFirebase(_ image: UIImage, completion: @escaping (URL?) -> Void) {
      guard let imageData = image.jpegData(compressionQuality: 0.8) else {
          print("Image data is nil")
          return
      }
      
      let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
    
      print("Storage Bucket URL: \(storageRef.bucket)")
      
      storageRef.putData(imageData, metadata: nil) { metadata, error in
          guard error == nil else {
              print("Failed to upload image:", error?.localizedDescription ?? "Unknown error")
              completion(nil)
              return
          }
          
          storageRef.downloadURL { url, error in
              if let downloadURL = url {
                  print("Image uploaded successfully: \(downloadURL)")
                  completion(downloadURL)
              } else {
                  print("Failed to retrieve download URL:", error?.localizedDescription ?? "Unknown error")
                  completion(nil)
              }
          }
      }
  }

  func parseImage(_ image:UIImage) {
    print("Unimplemented parse image")
  }
  
  func downloadImage() {
      isLoading = true
      let imageRef = storage.reference().child("test.png")
      print("Downloading image from: \(imageRef)")
      
      // Download the image as data
      imageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
        self.isLoading = false
          if let error = error {
              print("Error downloading image: \(error.localizedDescription)")
              return
          }
          
          if let data = data, let uiImage = UIImage(data: data) {
              self.image = uiImage
          }
      }
  }
}
