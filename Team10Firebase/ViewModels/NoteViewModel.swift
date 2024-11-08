//
//  NoteViewModel.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/8/24.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

class NoteViewModel: ObservableObject {
    @Published var note: Note?
    @Published var images: [UIImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    private var cancellables = Set<AnyCancellable>()

    init(note: Note) {
      self.note = note
    }

    func loadImages() {
      print("loading images")
      guard let imagePaths = note?.images else {
        print("No images found")
        return
      }
        isLoading = true
        errorMessage = nil
        images = []

        let dispatchGroup = DispatchGroup()

        for path in imagePaths {
            dispatchGroup.enter()
            let imageRef = storage.reference().child(path)
            imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error downloading image: \(error.localizedDescription)"
                    }
                } else if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.images.append(uiImage)
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
