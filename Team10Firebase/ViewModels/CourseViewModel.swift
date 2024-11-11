//
//  CourseViewModel.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/10/24.
//

// CourseViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class CourseViewModel: ObservableObject {
    @Published var course: Course
    @Published var courseFolders: [Folder] = []
    @Published var directCourseNotes: [Note] = []
    
    let firebase = Firebase()
    private var cancellables = Set<AnyCancellable>()
    
    init(course: Course) {
        self.course = course
        fetchFoldersForCourse()
        fetchDirectNotesForCourse()
    }
    
    func fetchFoldersForCourse() {
        firebase.getFolders { allFolders in
            self.courseFolders = allFolders.filter { folder in
                self.course.folders.contains(folder.id ?? "")
            }
        }
    }
    
    func fetchDirectNotesForCourse() {
        firebase.getNotes()
        self.directCourseNotes = firebase.notes.filter { note in
            self.course.notes.contains(note.id ?? "")
        }
    }
    
    func addFolder(_ folder: Folder) {
        self.courseFolders.append(folder)
    }
    
    func deleteFolder(_ folder: Folder, completion: @escaping (Error?) -> Void) {
        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
            if error == nil {
                self.courseFolders.removeAll { $0.id == folder.id }
            }
            completion(error)
        }
    }
    
    func addNote(_ note: Note) {
        self.directCourseNotes.append(note)
    }
    
    func deleteDirectNote(_ note: Note, completion: @escaping (Error?) -> Void) {
        firebase.deleteNote(note: note, folderID: nil) { error in
            if error == nil {
                self.directCourseNotes.removeAll { $0.id == note.id }
            }
            completion(error)
        }
    }
    
    func getMostRecentNoteForCourse() -> Note? {
        let sortedNotes = self.directCourseNotes.sorted { $0.createdAt > $1.createdAt }
        return sortedNotes.first
    }
}
