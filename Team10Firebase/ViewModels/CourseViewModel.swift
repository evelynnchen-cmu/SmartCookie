//
//  CourseViewModel.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/8/24.
//

import Foundation
import FirebaseFirestore
import Combine

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
            firebase.$notes
                .sink { [weak self] _ in
                    self?.fetchDirectNotes()
                }
                .store(in: &cancellables)
                
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
    
    func getMostRecentlyAccessedNote() -> Note? {
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
