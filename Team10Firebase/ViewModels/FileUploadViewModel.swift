//
//  FileUploadViewModel.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 11/25/24.
//

import SwiftUI
import Firebase

class FileUploadViewModel: ObservableObject {
    @Published var selectedFileURL: URL?
    @Published var uploadStatus: String? // For status updates or errors
    @Published var isUploading = false

//    func uploadPDF(toFirebase firebase: Firebase) {
//        guard let fileURL = selectedFileURL else { return }
//        
//        isUploading = true
//        firebase.uploadPDF(fileURL: fileURL) { result in
//            DispatchQueue.main.async {
//                self.isUploading = false
//                switch result {
//                case .success(let downloadURL):
//                    self.uploadStatus = "Upload successful! URL: \(downloadURL)"
//                case .failure(let error):
//                    self.uploadStatus = "Failed to upload PDF: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
}
