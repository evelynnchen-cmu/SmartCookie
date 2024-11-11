////
////  CourseViewModel.swift
////  Team10Firebase
////
////  Created by Vicky Chen on 11/10/24.
////
//
//// CourseViewModel.swift
//import Foundation
//import FirebaseFirestore
//import Combine
//
//class CourseViewModel: ObservableObject {
//    @Published var course: Course
//    @Published var courseFolders: [Folder] = []
//    @Published var directCourseNotes: [Note] = []
//    
//    let firebase = Firebase()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(course: Course) {
//        self.course = course
//        fetchFoldersForCourse()
//        fetchDirectNotesForCourse()
//    }
//    
//    func fetchFoldersForCourse() {
//        firebase.getFolders { allFolders in
//            self.courseFolders = allFolders.filter { folder in
//                self.course.folders.contains(folder.id ?? "")
//            }
//        }
//    }
//    
//    func fetchDirectNotesForCourse() {
//        firebase.getNotes()
//        self.directCourseNotes = firebase.notes.filter { note in
//            self.course.notes.contains(note.id ?? "")
//        }
//    }
//    
//    func addFolder(_ folder: Folder) {
//        self.courseFolders.append(folder)
//    }
//    
//    func deleteFolder(_ folder: Folder, completion: @escaping (Error?) -> Void) {
//        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
//            if error == nil {
//                self.courseFolders.removeAll { $0.id == folder.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func addNote(_ note: Note) {
//        self.directCourseNotes.append(note)
//    }
//    
//    func deleteDirectNote(_ note: Note, completion: @escaping (Error?) -> Void) {
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if error == nil {
//                self.directCourseNotes.removeAll { $0.id == note.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func getMostRecentNoteForCourse() -> Note? {
//        let sortedNotes = self.directCourseNotes.sorted { $0.createdAt > $1.createdAt }
//        return sortedNotes.first
//    }
//}

//import Foundation
//import FirebaseFirestore
//import Combine
//
//class CourseViewModel: ObservableObject {
//    @Published var course: Course
//    @Published var courseFolders: [Folder] = []
//    @Published var directCourseNotes: [Note] = []
//    
//    let firebase = Firebase()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(course: Course) {
//        self.course = course
//        observeFolderUpdates()
//        fetchDirectNotesForCourse()
//    }
//    
//    private func observeFolderUpdates() {
//        // Observe changes in Firebase's folders array and update courseFolders accordingly
//        firebase.$folders
//            .sink { [weak self] folders in
//                guard let self = self else { return }
//                self.courseFolders = folders.filter { folder in
//                    self.course.folders.contains(folder.id ?? "")
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    func fetchDirectNotesForCourse() {
//        firebase.getNotes()
//        self.directCourseNotes = firebase.notes.filter { note in
//            self.course.notes.contains(note.id ?? "")
//        }
//    }
//    
//    func addFolder(_ folder: Folder) {
//        self.courseFolders.append(folder)
//    }
//    
//    func deleteFolder(_ folder: Folder, completion: @escaping (Error?) -> Void) {
//        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
//            if error == nil {
//                self.courseFolders.removeAll { $0.id == folder.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func addNote(_ note: Note) {
//        self.directCourseNotes.append(note)
//    }
//    
//    func deleteDirectNote(_ note: Note, completion: @escaping (Error?) -> Void) {
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if error == nil {
//                self.directCourseNotes.removeAll { $0.id == note.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func getMostRecentNoteForCourse() -> Note? {
//        let sortedNotes = self.directCourseNotes.sorted { $0.createdAt > $1.createdAt }
//        return sortedNotes.first
//    }
//}
//







//import Foundation
//import FirebaseFirestore
//import Combine
//
//class CourseViewModel: ObservableObject {
//    @Published var course: Course
//    @Published var courseFolders: [Folder] = []
//    @Published var directCourseNotes: [Note] = []
//    
//    let firebase = Firebase()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(course: Course) {
//        self.course = course
//        fetchInitialFolders()
//        fetchDirectNotesForCourse()
//        observeFolderUpdates() // Keep observing for real-time changes
//    }
//    
//    func fetchInitialFolders() {
//        // Fetch folders immediately
//        firebase.getFolders { allFolders in
//            self.courseFolders = allFolders.filter { folder in
//                self.course.folders.contains(folder.id ?? "")
//            }
//        }
//    }
//
//    func observeFolderUpdates() {
//        // Observe changes in Firebase's folders array and update courseFolders accordingly
//        firebase.$folders
//            .sink { [weak self] folders in
//                guard let self = self else { return }
//                self.courseFolders = folders.filter { folder in
//                    self.course.folders.contains(folder.id ?? "")
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    func fetchDirectNotesForCourse() {
//        firebase.getNotes()
//        self.directCourseNotes = firebase.notes.filter { note in
//            self.course.notes.contains(note.id ?? "")
//        }
//    }
//    
//    func addFolder(_ folder: Folder) {
//        self.courseFolders.append(folder)
//    }
//    
//    func deleteFolder(_ folder: Folder, completion: @escaping (Error?) -> Void) {
//        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
//            if error == nil {
//                self.courseFolders.removeAll { $0.id == folder.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func addNote(_ note: Note) {
//        self.directCourseNotes.append(note)
//    }
//    
//    func deleteDirectNote(_ note: Note, completion: @escaping (Error?) -> Void) {
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if error == nil {
//                self.directCourseNotes.removeAll { $0.id == note.id }
//            }
//            completion(error)
//        }
//    }
//    
//    func getMostRecentNoteForCourse() -> Note? {
//        let sortedNotes = self.directCourseNotes.sorted { $0.createdAt > $1.createdAt }
//        return sortedNotes.first
//    }
//  
//  func fetchFoldersForCourse() async {
//      firebase.getFolders { allFolders in
//          self.courseFolders = allFolders.filter { folder in
//              self.course.folders.contains(folder.id ?? "")
//          }
//      }
//  }
//  
//}
//







//import Foundation
//import FirebaseFirestore
//import FirebaseStorage
//import Combine
//import UIKit
//
//class CourseViewModel: ObservableObject {
//    @Published var firebase = Firebase()
//    @Published var course: Course
//    @Published var courseFolders: [Folder] = []
//    @Published var directCourseNotes: [Note] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private var db = Firestore.firestore()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(course: Course) {
//        self.course = course
//        listenToFolders()
//        listenToNotes()
//    }
//    
//    // Listen for real-time updates for folders
//     func listenToFolders() {
//        isLoading = true
//        db.collection("Folder").whereField("courseID", isEqualTo: course.id ?? "")
//            .addSnapshotListener { [weak self] querySnapshot, error in
//                guard let self = self else { return }
//                self.isLoading = false
//                if let error = error {
//                    self.errorMessage = "Error fetching folders: \(error.localizedDescription)"
//                    return
//                }
//                
//                self.courseFolders = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Folder.self)
//                } ?? []
//            }
//    }
//    
//    // Listen for real-time updates for notes
//     func listenToNotes() {
//        isLoading = true
//        db.collection("Note").whereField("courseID", isEqualTo: course.id ?? "")
//            .addSnapshotListener { [weak self] querySnapshot, error in
//                guard let self = self else { return }
//                self.isLoading = false
//                if let error = error {
//                    self.errorMessage = "Error fetching notes: \(error.localizedDescription)"
//                    return
//                }
//                
//                self.directCourseNotes = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Note.self)
//                } ?? []
//            }
//    }
//
//    // Function to add a new folder asynchronously
//  func addFolder(folderName: String, completion: @escaping (Error?) -> Void) {
//      guard let courseID = course.id, let userID = course.userID else {
//          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid course or user ID"]))
//          return
//      }
//
//      let folder = Folder(id: nil, userID: userID, folderName: folderName, courseID: courseID, notes: [], fileLocation: "")
//
//      do {
//          try db.collection("Folder").addDocument(from: folder) { error in
//              if let error = error {
//                  print("Error creating folder: \(error.localizedDescription)")
//              }
//              completion(error)
//          }
//      } catch {
//          print("Error creating folder: \(error.localizedDescription)")
//          completion(error)
//      }
//  }
//
//
//
//
//    // Function to add a new note asynchronously
//  // Function to add a new note asynchronously
//  func addNote(noteTitle: String, noteContent: String, completion: @escaping (Error?) -> Void) {
//      guard let courseID = course.id, let userID = course.userID else {
//          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid course or user ID"]))
//          return
//      }
//
//      // Create a new Note instance, providing values for all non-optional properties in the struct
//      let note = Note(
//          id: nil,
//          userID: userID,
//          title: noteTitle,
//          summary: "Summary of \(noteTitle)",
//          content: noteContent,
//          images: [],
//          createdAt: Date(),
//          courseID: courseID,
//          fileLocation: "",
//          lastAccessed: nil  // Assuming it's okay for this to be nil initially
//      )
//
//      // Attempt to add the note to the Firestore database
//      do {
//          try db.collection("Note").addDocument(from: note) { error in
//              DispatchQueue.main.async {
//                  completion(error)
//              }
//          }
//      } catch {
//          completion(error)
//      }
//  }
//
//}







import Foundation
import FirebaseFirestore
import Combine

class CourseViewModel: ObservableObject {
    @Published var course: Course
    @Published var courseFolders: [Folder] = []
    @Published var directCourseNotes: [Note] = []
    @Published var isLoading = false // Add this property
    @Published var errorMessage: String? // Add this property
    
    let firebase = Firebase() // Assuming Firebase is a custom class managing Firestore interactions
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore() // Add this property for Firestore access
    
    init(course: Course) {
        self.course = course
        observeFolderUpdates()
        observeNoteUpdates()
    }
    
    // Observe folder updates in real-time from Firebase
    private func observeFolderUpdates() {
        firebase.$folders // Assuming Firebase has a published property `folders`
            .sink { [weak self] folders in
                guard let self = self else { return }
                // Filter folders based on course relationship
                self.courseFolders = folders.filter { folder in
                    self.course.folders.contains(folder.id ?? "")
                }
            }
            .store(in: &cancellables)
    }
    
    // Observe note updates in real-time from Firebase
    private func observeNoteUpdates() {
        firebase.$notes // Assuming Firebase has a published property `notes`
            .sink { [weak self] notes in
                guard let self = self else { return }
                // Filter notes based on course relationship
                self.directCourseNotes = notes.filter { note in
                    self.course.notes.contains(note.id ?? "")
                }
            }
            .store(in: &cancellables)
    }
    
    // Function to add a new folder
    func addFolder(_ folder: Folder) {
        self.courseFolders.append(folder)
    }
    
    // Function to delete a folder and update the view model
    func deleteFolder(_ folder: Folder, completion: @escaping (Error?) -> Void) {
        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
            if error == nil {
                // Remove the folder from local array if deletion is successful
                self.courseFolders.removeAll { $0.id == folder.id }
            }
            completion(error)
        }
    }
    
    // Function to add a new note
    func addNote(_ note: Note) {
        self.directCourseNotes.append(note)
    }
    
    // Function to delete a note and update the view model
    func deleteDirectNote(_ note: Note, completion: @escaping (Error?) -> Void) {
        firebase.deleteNote(note: note, folderID: nil) { error in
            if error == nil {
                // Remove the note from local array if deletion is successful
                self.directCourseNotes.removeAll { $0.id == note.id }
            }
            completion(error)
        }
    }
    
    // Get the most recent note for the course
    func getMostRecentNoteForCourse() -> Note? {
        return self.directCourseNotes.sorted { $0.createdAt > $1.createdAt }.first
    }
  
  
  func listenToFolders() {
      isLoading = true
      db.collection("Folder").whereField("courseID", isEqualTo: course.id ?? "")
          .addSnapshotListener { [weak self] querySnapshot, error in
              guard let self = self else { return }
              self.isLoading = false
              if let error = error {
                  self.errorMessage = "Error fetching folders: \(error.localizedDescription)"
                  return
              }
              
              self.courseFolders = querySnapshot?.documents.compactMap { document in
                  try? document.data(as: Folder.self)
              } ?? []
          }
  }

  
  func listenToDirectNotes() {
      isLoading = true
      db.collection("Note")
          .whereField("courseID", isEqualTo: course.id ?? "")
          .whereField("folderID", isEqualTo: NSNull())  // Ensure we're only getting notes outside folders
          .addSnapshotListener { [weak self] querySnapshot, error in
              guard let self = self else { return }
              self.isLoading = false
              if let error = error {
                  self.errorMessage = "Error fetching direct notes: \(error.localizedDescription)"
                  return
              }
              
              self.directCourseNotes = querySnapshot?.documents.compactMap { document in
                  try? document.data(as: Note.self)
              } ?? []
          }
  }



}
