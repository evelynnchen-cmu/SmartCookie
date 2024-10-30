//
//  Firebase.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/29/24.
//

import Foundation
import FirebaseFirestore

class Firebase: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var courses: [Course] = []
    @Published var notes: [Note] = []
    @Published var folders: [Folder] = []
    @Published var mcQuestions: [MCQuestion] = []
    
    private let courseCollection = "Course"
    private let noteCollection = "Note"
    private let folderCollection = "Folder"
    private let mcQuestionCollection = "MCQuestion"
  
    // get methods
    func getCourses() {
        db.collection(courseCollection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching courses: \(error.localizedDescription)")
                return
            }
            
            self.courses = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Course.self)
            } ?? []
            
            print("Total courses fetched: \(self.courses.count)")
            for course in self.courses {
                print("Fetched course: \(course)")
            }
        }
    }

    func getNotes() {
        db.collection(noteCollection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching notes: \(error.localizedDescription)")
                return
            }
            
            self.notes = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Note.self)
            } ?? []
            
            print("Total notes fetched: \(self.notes.count)")
            for note in self.notes {
                print("Fetched note: \(note)")
            }
        }
    }

    func getFolders() {
        db.collection(folderCollection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching folders: \(error.localizedDescription)")
                return
            }
            
            self.folders = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Folder.self)
            } ?? []
            
            print("Total folders fetched: \(self.folders.count)")
            for folder in self.folders {
                print("Fetched folder: \(folder)")
            }
        }
    }

    func getMCQuestions() {
        db.collection(mcQuestionCollection).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching MCQuestions: \(error.localizedDescription)")
                return
            }

            self.mcQuestions = querySnapshot?.documents.compactMap { document in
                try? document.data(as: MCQuestion.self)
            } ?? []

            print("Total MCQuestions fetched: \(self.mcQuestions.count)")
            for mcQuestion in self.mcQuestions {
                print("Fetched MCQuestion: \(mcQuestion)")
            }
        }
    }
}
