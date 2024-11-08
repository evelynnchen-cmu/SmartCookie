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
  // @Published var images: UIImage?
//  @Published var images: [UIImage] = []
//  @Published var isLoading = false
//  @Published var errorMessage: String?
  private let storage = Storage.storage()

  // Returns a HTTP url to the image
  // func uploadImageToFirebase(_ image: UIImage, completion: @escaping (URL?) -> Void) {
  //     guard let imageData = image.jpegData(compressionQuality: 0.8) else {
  //         print("Image data is nil")
  //         return
  //     }
      
  //     let storageRef = storage.reference().child("\(UUID().uuidString).jpg")
    
  //     print("Storage Bucket URL: \(storageRef.bucket)")
      
  //     storageRef.putData(imageData, metadata: nil) { metadata, error in
  //         guard error == nil else {
  //             print("Failed to upload image:", error?.localizedDescription ?? "Unknown error")
  //             completion(nil)
  //             return
  //         }
          
  //         storageRef.downloadURL { url, error in
  //             if let downloadURL = url {
  //                 print("Image uploaded successfully: \(downloadURL)")
  //                 completion(downloadURL)
  //             } else {
  //                 print("Failed to retrieve download URL:", error?.localizedDescription ?? "Unknown error")
  //                 completion(nil)
  //             }
  //         }
  //     }
  // }
  // Returns a file path to the image in FB Storage
  func uploadImageToFirebase(_ image: UIImage, completion: @escaping (String?) -> Void) {
    var imageData = image.jpegData(compressionQuality: 0.8)
    if imageData == nil {
        imageData = image.pngData()
    }
    guard let finalImageData = imageData else {
        print("Image data is nil")
        completion(nil)
        return
    }
    
    let filePath = "\(UUID().uuidString).jpg"
    let storageRef = storage.reference().child(filePath)
    
    storageRef.putData(finalImageData, metadata: nil) { metadata, error in
        guard error == nil else {
            print("Failed to upload image:", error?.localizedDescription ?? "Unknown error")
            completion(nil)
            return
        }
        
        print("Image uploaded successfully: \(filePath)")
        completion(filePath)
    }
  }
  
  // func downloadImage(note: Note) {
  //     isLoading = true

  //     let imageRef = storage.reference().child("test.png")
  //     print("Downloading image from: \(imageRef)")
      
  //     // Download the image as data
  //     imageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
  //       self.isLoading = false
  //         if let error = error {
  //             print("Error downloading image: \(error.localizedDescription)")
  //             return
  //         }
          
  //         if let data = data, let uiImage = UIImage(data: data) {
  //             self.image = uiImage
  //         }
  //     }
  // }
//  func loadImages(note: Note) {
//        var imagePaths = note.images
//        isLoading = true
//        errorMessage = nil
//        images = []
//
//        let dispatchGroup = DispatchGroup()
//
//        for path in imagePaths {
//            dispatchGroup.enter()
//            let imageRef = storage.reference().child(path)
//            imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self.errorMessage = "Error downloading image: \(error.localizedDescription)"
//                    }
//                } else if let data = data, let uiImage = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self.images.append(uiImage)
//                    }
//                }
//                dispatchGroup.leave()
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            self.isLoading = false
//        }
//    }
}
