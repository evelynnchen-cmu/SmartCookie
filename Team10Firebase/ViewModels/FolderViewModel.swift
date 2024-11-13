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
    @Published var notes: [Note] = [] // Will store only filtered notes for this folder
    @Published var errorMessage: String?
    private var firebase: Firebase
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>() // To manage subscriptions

  init(firebase: Firebase, folder: Folder, notes: [Note]) {
        self.firebase = firebase
        self.folder = folder
        // Observe firebase.notes and filter them for this folder
        self.notes = notes
        fetchNotesByIDs()
//        firebase.$notes
//            .sink { [weak self] allNotes in
//                self?.notes = allNotes.filter { note in
//                    note.courseID == folder.courseID && folder.notes.contains(note.id ?? "")
//                }
//            }
//            .store(in: &cancellables)
    }
  
  
  private func fetchNotesByIDs() {
    let noteIDs = folder.notes
    var fetchedNotes: [Note] = []
    
    guard !noteIDs.isEmpty else {
      return
    }
    
    let dispatchGroup = DispatchGroup()
    for noteID in noteIDs {
      dispatchGroup.enter()
      db.collection("notes").document(noteID).getDocument { [weak self] document, error in
        defer { dispatchGroup.leave() }
        if let error = error {
          self?.errorMessage = "Error fetching note \(noteID): \(error.localizedDescription)"
        } else if let document = document, document.exists, let note = try? document.data(as: Note.self) {
          fetchedNotes.append(note)
        }
        
      }
    }
    dispatchGroup.notify(queue: .main) { [weak self] in
      self?.notes = fetchedNotes
      print("Fetched \(self?.notes.count ?? 0) notes for folder \(self?.folder.id ?? "")")
    }
  }
  
  
  
    
    // Create a note within this folder
    func createNote(
        title: String,
        summary: String,
        content: String,
        images: [String] = [],
        completion: @escaping (Error?) -> Void
    ) {
        firebase.createNote(
            title: title,
            summary: summary,
            content: content,
            images: images,
            course: Course(
                id: folder.courseID,
                userID: folder.userID ?? "",
                courseName: "",
                folders: [],
                notes: [],
                fileLocation: folder.fileLocation
            ),
            folder: folder
        ) { error in
            if let error = error {
                self.errorMessage = "Error creating note: \(error.localizedDescription)"
            }
            completion(error)
        }
    }
    
    // Delete a specific note within the folder
    func deleteNote(_ note: Note, completion: @escaping (Error?) -> Void) {
        firebase.deleteNote(note: note, folderID: folder.id) { error in
            if let error = error {
                self.errorMessage = "Error deleting note: \(error.localizedDescription)"
                completion(error)
            } else {
                completion(nil) // FolderView will update automatically as firebase.notes changes
            }
        }
    }
    
    // Utility function to retrieve the most recent note summary within the folder
    func getRecentNoteSummary() -> Folder.RecentNoteSummary? {
        guard let mostRecentNote = notes.sorted(by: { $0.createdAt > $1.createdAt }).first else {
            return nil
        }
        
        return Folder.RecentNoteSummary(
            noteID: mostRecentNote.id,
            title: mostRecentNote.title,
            summary: mostRecentNote.summary,
            createdAt: mostRecentNote.createdAt
        )
    }

    // Update recent note summary in Firestore
    func updateRecentNoteSummary() {
        let recentSummary = getRecentNoteSummary()
        folder.recentNoteSummary = recentSummary
        guard let folderID = folder.id else { return }
        
        db.collection("Folder").document(folderID).updateData([
            "recentNoteSummary": [
                "noteID": recentSummary?.noteID ?? "",
                "title": recentSummary?.title ?? "",
                "summary": recentSummary?.summary ?? "",
                "createdAt": recentSummary?.createdAt ?? Date()
            ]
        ]) { error in
            if let error = error {
                self.errorMessage = "Error updating recent note summary: \(error.localizedDescription)"
            }
        }
    }
}

