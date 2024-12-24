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
    @Published var imagesLoaded = false
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    private var cancellables = Set<AnyCancellable>()
    @Published var course: Course?
    private var firebase = Firebase()

    init(note: Note) {
      self.note = note
      firebase.getCourse(courseID: note.courseID ?? "") {foundCourse in
          if let course = foundCourse {
            self.course = course
          } else {
            print("Failed to get course")
            self.course = nil
          }
      }
    }

    func loadImages() {
        guard let imagePaths = note?.images else {
            print("No images found")
            return
        }
        isLoading = true
        errorMessage = nil
        images = []

        let dispatchGroup = DispatchGroup()
        var loadedImages: [String: UIImage] = [:]

        for path in imagePaths {
            dispatchGroup.enter()
            let imageRef = Storage.storage().reference().child(path)
            imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error downloading image: \(error.localizedDescription)"
                    }
                } else if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        loadedImages[path] = uiImage
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.images = imagePaths.compactMap { loadedImages[$0] }
            self.isLoading = false
            if self.images.isEmpty {
                self.errorMessage = "No images loaded"
            }
        }
    }
}
