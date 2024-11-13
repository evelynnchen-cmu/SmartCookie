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
            self.imagesLoaded = true
        }
    }

// TODO: refactor so we don't copy this function again

    func parseImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        let base64Image = imageData.base64EncodedString()
        //  The OpenAI API key loaded from the Secrets.plist file.
        let openAIKey: String = {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: filePath),
                let key = plist["OpenAIKey"] as? String else {
                fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
            }
            return key
        }()

        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                Message(
                    role: "user",
                    content: [
                        MessageContent(type: "text", text: "What’s in this image?", imageURL: nil),
                        MessageContent(type: "image_url", text: nil, imageURL: ImageURL(url: "data:image/jpeg;base64,\(base64Image)"))
                    ]
                )
            ],
            maxTokens: 300
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            print("Failed to create JSON payload.")
            exit(0)
        }

        let startTime = Date()

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error.")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                for choice in jsonResponse.choices {
                    print("Response: \(choice.message.content)")
                }
                if let content = jsonResponse.choices.first?.message.content {
                    completion(content)
                }

            } catch {
                print("Failed to parse JSON: \(error)")
                completion(nil)
            }

            print("Time taken for request: \(timeInterval) seconds")
        }

        task.resume()

    }
}
