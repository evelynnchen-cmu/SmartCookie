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

