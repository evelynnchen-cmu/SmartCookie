//
//  MockFirebase.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/11/24.
//


@testable import Team10Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import Combine

class MockFirebase {
    @Published var courses: [Course] = []
    @Published var notes: [Note] = []
    @Published var folders: [Folder] = []
    @Published var mcQuestions: [MCQuestion] = []
    @Published var notifications: [Team10Firebase.Notification] = []
    @Published var users: [User] = []
    
    var shouldFailOperations = false
    var lastError: Error? = nil
    var mockDelay: TimeInterval = 0
    
    var createNoteCalled = false
    var deleteNoteCalled = false
    var updateNoteCalled = false
    
    func getFirstUser(completion: @escaping (User?) -> Void) {
        if shouldFailOperations {
            completion(nil)
            return
        }
        
        let mockUser = User(
            id: "mock-user-id",
            name: "Mock User",
            notifications: [],
            streak: User.Streak(
                currentStreakLength: 0,
                lastQuizCompletedAt: nil
            ),
            courses: [],
            settings: User.Settings(
                notificationsEnabled: true,
                notificationFrequency: "Daily",
                notesOnlyQuizScope: false,
                notesOnlyChatScope: false
            ),
            quizzes: []
        )
        completion(mockUser)
    }
    
    func createNote(
        title: String,
        summary: String,
        content: String,
        images: [String] = [],
        course: Course,
        folder: Folder? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        createNoteCalled = true
        
        if shouldFailOperations {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
            return
        }
        
        let note = Note(
            id: UUID().uuidString,
            userID: course.userID,
            title: title,
            summary: summary,
            content: content,
            images: images,
            createdAt: Date(),
            courseID: course.id ?? "",
            fileLocation: "\(course.id ?? "")/\(folder?.id ?? "")",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        
        notes.append(note)
        completion(nil)
    }
    
    func deleteNote(note: Note, folderID: String?, completion: @escaping (Error?) -> Void) {
        deleteNoteCalled = true
        
        if shouldFailOperations {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock delete error"]))
            return
        }
        
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
        }
        completion(nil)
    }
    
    func updateNoteContent(noteID: String, newContent: String) {
        updateNoteCalled = true
        
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].content = newContent
        }
    }
    
    func getMostRecentlyUpdatedNotes(limit: Int = 4) -> [Note] {
        let sortedNotes = notes.sorted { note1, note2 in
            let date1 = note1.lastUpdated ?? note1.createdAt
            let date2 = note2.lastUpdated ?? note2.createdAt
            return date1 > date2
        }
        
        return Array(sortedNotes.prefix(limit))
    }
}
