
@testable import Team10Firebase
import FirebaseFirestore
import FirebaseStorage
import Foundation
import Combine

class MockFirebase: Firebase {
    override var courses: [Course] {
        get { _courses }
        set { _courses = newValue }
    }
    override var notes: [Note] {
        get { _notes }
        set { _notes = newValue }
    }
    override var folders: [Folder] {
        get { _folders }
        set { _folders = newValue }
    }
    override var mcQuestions: [MCQuestion] {
        get { _mcQuestions }
        set { _mcQuestions = newValue }
    }
    override var notifications: [Team10Firebase.Notification] {
        get { _notifications }
        set { _notifications = newValue }
    }
    override var users: [User] {
        get { _users }
        set { _users = newValue }
    }
    
    @Published private var _courses: [Course] = []
    @Published private var _notes: [Note] = []
    @Published private var _folders: [Folder] = []
    @Published private var _mcQuestions: [MCQuestion] = []
    @Published private var _notifications: [Team10Firebase.Notification] = []
    @Published private var _users: [User] = []
    
    var shouldFailOperations = false
    var lastError: Error? = nil
    var mockDelay: TimeInterval = 0
    
    var createNoteCalled = false
    var deleteNoteCalled = false
    var updateNoteCalled = false
    
    override func getFirstUser(completion: @escaping (User?) -> Void) {
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
    
    override func createNote(
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
        
        _notes.append(note)
        completion(nil)
    }
    
    override func deleteNote(note: Note, folderID: String?, completion: @escaping (Error?) -> Void) {
        deleteNoteCalled = true
        
        if shouldFailOperations {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock delete error"]))
            return
        }
        
        if let index = _notes.firstIndex(where: { $0.id == note.id }) {
            _notes.remove(at: index)
        }
        completion(nil)
    }
    
    override func updateNoteContent(noteID: String, newContent: String) {
        updateNoteCalled = true
        
        if let index = _notes.firstIndex(where: { $0.id == noteID }) {
            _notes[index].content = newContent
        }
    }
    
    override func getMostRecentlyUpdatedNotes(limit: Int = 4) -> [Note] {
        let sortedNotes = _notes.sorted { note1, note2 in
            let date1 = note1.lastUpdated ?? note1.createdAt
            let date2 = note2.lastUpdated ?? note2.createdAt
            return date1 > date2
        }
        
        return Array(sortedNotes.prefix(limit))
    }

    override func getNotesById(noteIDs: [String], completion: @escaping ([Note]) -> Void) {
        if shouldFailOperations {
            completion([])
            return
        }
        
        let filteredNotes = _notes.filter { note in
            noteIDs.contains(note.id ?? "")
        }
        completion(filteredNotes)
    }
    
    override func getFolder(folderID: String, completion: @escaping (Folder?) -> Void) {
        if shouldFailOperations {
            completion(nil)
            return
        }
        
        let folder = _folders.first { $0.id == folderID }
        completion(folder)
    }
}
