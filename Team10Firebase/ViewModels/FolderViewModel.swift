//
//  FolderViewModel.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/12/24.
//

//import Foundation
//import FirebaseFirestore
//import FirebaseStorage
//import Combine
//import UIKit
//
//class FolderViewModel: ObservableObject {
//  @Published var folder: Folder?
//  
//  
//  init(folder: Folder) {
//    self.folder = folder
//  }
//}



import Foundation
import FirebaseFirestore
import Combine

class FolderViewModel: ObservableObject {
    @Published var folder: Folder
    @Published var course: Course
    @Published var notes: [Note] = []
    @Published var errorMessage: String?
    private var firebase: Firebase
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

  init(firebase: Firebase, folder: Folder, course: Course) {
      self.firebase = firebase
      self.folder = folder
      self.course = course
      self.notes = []
      fetchNotesByIDs()
    }
  
  
  private func fetchNotesByIDs() {
    let noteIDs = folder.notes
    print("Note IDS to fetch", folder.notes)

    firebase.getNotesById(noteIDs: noteIDs) { notes in
      self.notes = notes
      print("Fetched \(self.notes.count) notes for folder \(self.folder.id ?? "")")
    }
  }
  
  
  
  
//    func createNote(
//        title: String,
//        summary: String,
//        content: String,
//        images: [String] = [],
//        completion: @escaping (Error?) -> Void
//    ) {
//        firebase.createNote(
//            title: title,
//            summary: summary,
//            content: content,
//            images: images,
//            course: Course(
//                id: folder.courseID,
//                userID: folder.userID ?? "",
//                courseName: "",
//                folders: [],
//                notes: [],
//                fileLocation: folder.fileLocation
//            ),
//            folder: folder
//        ) { error in
//            if let error = error {
//                self.errorMessage = "Error creating note: \(error.localizedDescription)"
//            }
//            completion(error)
//        }
//    }
    
//    func deleteNote(_ note: Note, completion: @escaping (Error?) -> Void) {
//        firebase.deleteNote(note: note, folderID: folder.id) { error in
//            if let error = error {
//                self.errorMessage = "Error deleting note: \(error.localizedDescription)"
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        }
//    }
    
//    func getRecentNoteSummary() -> Folder.RecentNoteSummary? {
//        guard let mostRecentNote = notes.sorted(by: { $0.createdAt > $1.createdAt }).first else {
//            return nil
//        }
//        
//        return Folder.RecentNoteSummary(
//            noteID: mostRecentNote.id,
//            title: mostRecentNote.title,
//            summary: mostRecentNote.summary,
//            createdAt: mostRecentNote.createdAt
//        )
//    }
//
//    func updateRecentNoteSummary() {
//        let recentSummary = getRecentNoteSummary()
//        folder.recentNoteSummary = recentSummary
//        guard let folderID = folder.id else { return }
//        
//        db.collection("Folder").document(folderID).updateData([
//            "recentNoteSummary": [
//                "noteID": recentSummary?.noteID ?? "",
//                "title": recentSummary?.title ?? "",
//                "summary": recentSummary?.summary ?? "",
//                "createdAt": recentSummary?.createdAt ?? Date()
//            ]
//        ]) { error in
//            if let error = error {
//                self.errorMessage = "Error updating recent note summary: \(error.localizedDescription)"
//            }
//        }
//    }
  
  func fetchNotes() {
    updateFolderNotes()
    firebase.getNotes()
    notes = firebase.notes.filter { $0.courseID == course.id &&
      folder.notes.contains($0.id ?? "") == true}
  }

  func updateFolderNotes() {
    firebase.getFolder(folderID: folder.id ?? "") { folder in
      self.folder = folder ?? self.folder
    }
  }

}

