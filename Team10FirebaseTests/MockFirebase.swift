
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
    var deleteImagesCalled = false
    
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

    override func getCourses() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getCourses error"])
            return
        }
        // Mock implementation
        _courses = [
            Course(id: "course1", userID: "user1", courseName: "Course 1", folders: [], notes: [], fileLocation: "/course1/"),
            Course(id: "course2", userID: "user2", courseName: "Course 2", folders: [], notes: [], fileLocation: "/course2/")
        ]
    }

    override func getNotes() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getNotes error"])
            return
        }
        // Mock implementation
        _notes = [
            Note(id: "note1", userID: "user1", title: "Note 1", summary: "Summary 1", content: "Content 1", images: [], createdAt: Date(), courseID: "course1", fileLocation: "/course1/note1", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note2", userID: "user2", title: "Note 2", summary: "Summary 2", content: "Content 2", images: [], createdAt: Date(), courseID: "course2", fileLocation: "/course2/note2", lastAccessed: Date(), lastUpdated: Date())
        ]
    }

    override func getMCQuestions() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getMCQuestions error"])
            return
        }
        // Mock implementation
        _mcQuestions = [
            MCQuestion(id: "question1", question: "Question 1", potentialAnswers: ["A", "B", "C", "D"], correctAnswer: 0, userID: "user1", noteID: "note1", attemptCount: 0, lastAttemptDate: nil),
            MCQuestion(id: "question2", question: "Question 2", potentialAnswers: ["A", "B", "C", "D"], correctAnswer: 1, userID: "user2", noteID: "note2", attemptCount: 0, lastAttemptDate: nil)
        ]
    }

    override func getNotifications() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getNotifications error"])
            return
        }
        // Mock implementation
        _notifications = [
            Notification(id: "notification1", type: "Type 1", message: "Message 1", quizID: "quiz1", scheduledAt: Date(), userID: "user1"),
            Notification(id: "notification2", type: "Type 2", message: "Message 2", quizID: "quiz2", scheduledAt: Date(), userID: "user2")
        ]
    }

    override func getUsers() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getUsers error"])
            return
        }
        // Mock implementation
        _users = [
            User(id: "user1", name: "User 1", notifications: [], streak: User.Streak(currentStreakLength: 0, lastQuizCompletedAt: nil), courses: [], settings: User.Settings(notificationsEnabled: true, notificationFrequency: "Daily", notesOnlyQuizScope: false, notesOnlyChatScope: false), quizzes: []),
            User(id: "user2", name: "User 2", notifications: [], streak: User.Streak(currentStreakLength: 0, lastQuizCompletedAt: nil), courses: [], settings: User.Settings(notificationsEnabled: true, notificationFrequency: "Weekly", notesOnlyQuizScope: false, notesOnlyChatScope: false), quizzes: [])
        ]
    }

    override func getFolders(completion: @escaping ([Folder]) -> Void) {
        if shouldFailOperations {
            completion([])
            return
        }
        // Mock implementation
        _folders = [
            Folder(id: "folder1", userID: "user1", folderName: "Folder 1", courseID: "course1", notes: [], fileLocation: "/course1/folder1", recentNoteSummary: nil),
            Folder(id: "folder2", userID: "user2", folderName: "Folder 2", courseID: "course2", notes: [], fileLocation: "/course2/folder2", recentNoteSummary: nil)
        ]
        completion(_folders)
    }

    override func getCourse(courseID: String, completion: @escaping (Course?) -> Void) {
        if shouldFailOperations {
            completion(nil)
            return
        }
        // Mock implementation
        let course = _courses.first { $0.id == courseID }
        completion(course)
    }

    override func getFolder(folderID: String, completion: @escaping (Folder?) -> Void) {
        if shouldFailOperations {
            completion(nil)
            return
        }
        // Mock implementation
        let folder = _folders.first { $0.id == folderID }
        completion(folder)
    }

    override func getNotesById(noteIDs: [String], completion: @escaping ([Note]) -> Void) {
        if shouldFailOperations {
            completion([])
            return
        }
        // Mock implementation
        let notes = _notes.filter { noteIDs.contains($0.id ?? "") }
        completion(notes)
    }

    override func getFoldersById(folderIDs: [String], completion: @escaping ([Folder]) -> Void) {
        if shouldFailOperations {
            completion([])
            return
        }
        // Mock implementation
        let folders = _folders.filter { folderIDs.contains($0.id ?? "") }
        completion(folders)
    }

    override func getIncorrectQuestions(userID: String, noteID: String, completion: @escaping ([MCQuestion]) -> Void) {
        if shouldFailOperations {
            completion([])
            return
        }
        // Mock implementation
        let questions = _mcQuestions.filter { $0.userID == userID && $0.noteID == noteID }
        completion(questions)
    }
  
  override func createNote(
      title: String,
      summary: String,
      content: String,
      images: [String] = [],
      course: Course,
      folder: Folder? = nil,
      completion: @escaping (Note?, Error?) -> Void
  ) {
      createNoteCalled = true
      
      if shouldFailOperations {
          completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
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
      completion(note, nil)
  }
  
  override func createNoteWithIDs(title: String, content: String, images: [String], courseID: String, folderID: String?, userID: String, completion: @escaping (Note?) -> Void) async {
          createNoteCalled = true
          if shouldFailOperations {
              lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock create note error"])
              completion(nil)
          } else {
              let note = Note(
                  id: UUID().uuidString,
                  userID: userID,
                  title: title,
                  summary: "",
                  content: content,
                  images: images,
                  createdAt: Date(),
                  courseID: courseID,
                  fileLocation: "\(courseID)/\(folderID ?? "")",
                  lastAccessed: Date(),
                  lastUpdated: Date()
              )
              _notes.append(note)
              completion(note)
          }
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

    override func deleteImages(imagePaths: [String], completion: @escaping (Error?) -> Void) {
        deleteImagesCalled = true
        if shouldFailOperations {
            completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Mock delete error"]))
        } else {
            completion(nil)
        }
    }
}
