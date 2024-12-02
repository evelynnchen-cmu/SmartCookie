////
////  CourseViewModel.swift
////  Team10Firebase
////
////  Created by Vicky Chen on 11/27/24.
////
//import Foundation
//import FirebaseFirestore
//import Combine
//
//class CourseViewModel: ObservableObject {
//  @Published var course: Course
//  @Published var folders: [Folder] = []
//  @Published var notes: [Note] = []
//  @Published var errorMessage: String?
//  private var firebase: Firebase
//  private var db = Firestore.firestore()
//  private var cancellables = Set<AnyCancellable>()
//  
//  init(firebase: Firebase, course: Course) {
//    self.firebase = firebase
//    self.folders = []
//    self.notes = []
//    self.course = course
//    fetchFolders()
//    fetchDirectNotes()
//  }
//  
//  private func fetchFolders() {
//    let folderIDs = course.folders
//    firebase.getFoldersById(folderIDs: folderIDs) { folders in
//      self.folders = folders
//      print("Fetched \(self.folders.count) folders for course \(self.course.id ?? "")")
//      
//      self.folders.forEach { folder in
//        self.firebase.getNotesById(noteIDs: folder.notes) { notes in
//          folder.notes = notes.map { $0.id ?? ""}
//        }
//        
//      }
//      
//    }
//  }
//  
//  
//  private func fetchDirectNotes() {
//    let noteIDs = course.notes
//    print("Direct Note IDS to fetch", course.notes)
//    
//    firebase.getNotesById(noteIDs: noteIDs) { notes in
//      self.notes = notes
//      print("Fetched \(self.notes.count) directNotes for course \(self.course.id ?? "")")
//    }
//  }
//  
//  func fetchNotes() {
//    updatedCourseNotes()
//  }
//  
//  func updatedCourseNotes() {
//    firebase.get
//  }
//  
//}







//import Foundation
//import FirebaseFirestore
//import Combine
//
//class CourseViewModel: ObservableObject {
//    @Published var course: Course
//    @Published var folders: [Folder] = []
//    @Published var notes: [Note] = []
//    @Published var errorMessage: String?
//    @Published var firebase: Firebase
//    private var db = Firestore.firestore()
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(firebase: Firebase, course: Course) {
//        self.firebase = firebase
//        self.course = course
//        self.folders = []
//        self.notes = []
//        fetchFolders()
//        fetchDirectNotes()
//    }
//    
//    /// Fetches folders associated with the course
//    func fetchFolders() {
//        let folderIDs = course.folders
//
//        firebase.getFoldersById(folderIDs: folderIDs) { folders in
//            self.folders = folders
//            print("Fetched \(self.folders.count) folders for course \(self.course.id ?? "")")
//
//            // Fetch notes for each folder
//            for index in self.folders.indices {
//                let folder = self.folders[index] // Access the folder at the current index
//                self.firebase.getNotesById(noteIDs: folder.notes) { notes in
//                    self.folders[index].notes = notes.map { $0.id ?? "" } // Update the folder's notes
//                }
//            }
//        }
//    }
//
//    
//    /// Fetches notes directly associated with the course (not nested within folders)
//    func fetchDirectNotes() {
//        let noteIDs = course.notes
//        firebase.getNotesById(noteIDs: noteIDs) { notes in
//            self.notes = notes
//            print("Fetched \(self.notes.count) direct notes for course \(self.course.id ?? "")")
//        }
//    }
//    
//    /// Updates the course data
//    func updateCourseData() {
//        firebase.getCourse(courseID: course.id ?? "") { course in
//            self.course = course ?? self.course
//        }
//    }
//    
//    /// Fetches both folders and notes to ensure all associated data is up-to-date
//    func refreshCourseData() {
//        fetchFolders()
//        fetchDirectNotes()
//    }
//    
//    /// Handles creating a folder within the course
//    func createFolder(
//        folderName: String,
//        completion: @escaping (Error?) -> Void
//    ) {
//        Task {
//            do {
//                try await firebase.createFolder(folderName: folderName, course: course)
//                self.fetchFolders() // Refresh folders after creating
//                completion(nil)
//            } catch {
//                self.errorMessage = "Error creating folder: \(error.localizedDescription)"
//                completion(error)
//            }
//        }
//    }
//
//    
//    /// Handles creating a note directly within the course
//    func createDirectNote(
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
//            course: course,
//            folder: nil
//        ) { error in
//            if let error = error {
//                self.errorMessage = "Error creating note: \(error.localizedDescription)"
//            } else {
//                self.fetchDirectNotes()
//            }
//            completion(error)
//        }
//    }
//    
//    /// Deletes a folder and its associated notes
//    func deleteFolder(folder: Folder, completion: @escaping (Error?) -> Void) {
//        guard let courseID = course.id else {
//            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Course ID is missing."]))
//            return
//        }
//
//        firebase.deleteFolder(folder: folder, courseID: courseID) { error in
//            if let error = error {
//                self.errorMessage = "Error deleting folder: \(error.localizedDescription)"
//            } else {
//                // Remove the folder locally
//                self.folders.removeAll { $0.id == folder.id }
//                self.fetchFolders()
//            }
//            completion(error)
//        }
//    }
//
//    
//    /// Deletes a direct note (not nested within a folder)
//    func deleteDirectNote(note: Note, completion: @escaping (Error?) -> Void) {
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if let error = error {
//                self.errorMessage = "Error deleting note: \(error.localizedDescription)"
//            } else {
//                self.notes.removeAll { $0.id == note.id }
//            }
//            completion(error)
//        }
//    }
//  
//  func fetchData() {
//      fetchFolders()
//      fetchDirectNotes()
//  }
//}
//

import Foundation
import FirebaseFirestore
import Combine


// CourseViewModel.swift
class CourseViewModel: ObservableObject {
    @Published var course: Course
    @Published var folders: [Folder] = []
    @Published var notes: [Note] = []
    @Published var firebase: Firebase
    private var cancellables = Set<AnyCancellable>()
    
    init(firebase: Firebase, course: Course) {
            self.firebase = firebase
            self.course = course
            setupSubscriptions()
            fetchData()
    }
  
    private func setupSubscriptions() {
            // Listen for changes to Firebase's notes
            firebase.$notes
                .sink { [weak self] _ in
                    self?.fetchDirectNotes()
                }
                .store(in: &cancellables)
                
            // Monitor course updates
            firebase.getCourse(courseID: course.id ?? "") { [weak self] updatedCourse in
                if let updatedCourse = updatedCourse {
                    self?.course = updatedCourse
                    self?.fetchData()
                }
            }
      }
    
  
    func fetchData() {
        firebase.getNotes()
        fetchFolders()
        fetchDirectNotes()
    }
    
    func fetchFolders() {
        firebase.getFolders { [weak self] allFolders in
            guard let self = self else { return }
            self.folders = allFolders.filter { folder in
                self.course.folders.contains(folder.id ?? "")
            }
        }
    }
    
    func fetchDirectNotes() {
        self.notes = firebase.notes.filter { note in
            self.course.notes.contains(note.id ?? "")
        }
    }
    
    func getMostRecentNote() -> Note? {
        return notes.sorted { $0.createdAt > $1.createdAt }.first
    }
    
    func deleteNote(_ note: Note) {
        firebase.deleteNote(note: note, folderID: nil) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                self.fetchDirectNotes()
            }
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error deleting folder: \(error.localizedDescription)")
            } else {
                self.folders.removeAll { $0.id == folder.id }
                self.fetchFolders()
            }
        }
    }
}
