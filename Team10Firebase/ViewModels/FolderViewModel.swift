//
//  FolderViewModel.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/10/24.
//


import Foundation
import FirebaseFirestore
import Combine

class FolderViewModel: ObservableObject {
    @Published var folder: Folder
    @Published var course: Course
    @Published var notes: [Note] = []
    @Published var errorMessage: String?
    var firebase: Firebase
    var db = Firestore.firestore()
    
    init(firebase: Firebase, course: Course, folder: Folder) {
        self.firebase = firebase
        self.folder = folder
        self.course = course
        fetchNotesForFolder()
    }
    
    // Fetch notes that are specifically associated with this folder
    func fetchNotesForFolder() {
        firebase.getNotes() // Ensure notes are loaded into firebase.notes
        notes = firebase.notes.filter { note in
            note.courseID == folder.courseID && folder.notes.contains(note.id ?? "")
        }
    }
    
    // Delete a specific note within the folder
    func deleteNote(_ note: Note, completion: @escaping (Error?) -> Void) {
        firebase.deleteNote(note: note, folderID: folder.id) { error in
            if let error = error {
                self.errorMessage = "Error deleting note: \(error.localizedDescription)"
                completion(error)
            } else {
                // Refresh notes after successful deletion
                self.fetchNotesForFolder()
                completion(nil)
            }
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
                id: folder.courseID, // Using the course ID of this folder
                userID: folder.userID ?? "",
                courseName: "", // Placeholder as the name isn’t needed here
                folders: [],
                notes: [],
                fileLocation: folder.fileLocation
            ),
            folder: folder
        ) { error in
            if let error = error {
                self.errorMessage = "Error creating note: \(error.localizedDescription)"
            }
            // Fetch updated notes list after note creation
            self.fetchNotesForFolder()
            completion(error)
        }
    }
    
    // Utility function to retrieve the most recent note summary within the folder
    func getRecentNoteSummary() -> Folder.RecentNoteSummary? {
        guard let mostRecentNoteID = notes.sorted(by: { $0.createdAt > $1.createdAt }).first?.id else {
            return nil
        }
        
        return notes.first { $0.id == mostRecentNoteID }.flatMap { note in
            Folder.RecentNoteSummary(
                noteID: note.id,
                title: note.title,
                summary: note.summary,
                createdAt: note.createdAt
            )
        }
    }
    
    // Update recent note summary in the folder after note creation or deletion
    func updateRecentNoteSummary() {
        let recentSummary = getRecentNoteSummary()
        folder.recentNoteSummary = recentSummary
        guard let folderID = folder.id else { return }
        
        // Update recent note summary in Firestore
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
