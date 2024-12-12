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
  private let storage = Storage.storage()

  // Returns a file path to the image in FB Storage
  func uploadImageToFirebase(_ image: UIImage, completion: @escaping (String?) -> Void) {
    var imageData = image.jpegData(compressionQuality: 0.8)
    if imageData == nil {
        imageData = image.pngData()
    }
    guard let finalImageData = imageData else {
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

  func uploadImagesToFirebase(_ images: [UIImage], completion: @escaping ([String]?) -> Void) {
    var imagesToUpload = images
    var uploadedImages: [String] = []
    var errorOccurred = false
    var imagePaths: [String?] = Array(repeating: nil, count: images.count)
    let dispatchGroup = DispatchGroup()

    for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            uploadImageToFirebase(image) { path in
                imagePaths[index] = path
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if imagePaths.contains(where: { $0 == nil }) {
                completion(nil)
            } else {
                completion(imagePaths.compactMap { $0 })
            }
        }
  }
}
