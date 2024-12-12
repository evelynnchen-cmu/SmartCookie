//
//  FirebaseTests.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/11/24.
//

import XCTest
@testable import Team10Firebase

class FirebaseTests: XCTestCase {
    var mockFirebase: MockFirebase!
    var testCourse: Course!
    var testFolder: Folder!
    var testNote: Note!
    var testMCQuestion: MCQuestion!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        testCourse = Course(
            id: "test-course-id",
            userID: "test-user-id",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/test/"
        )
        testFolder = Folder(
            id: "test-folder-id",
            userID: "test-user-id",
            folderName: "Test Folder",
            courseID: testCourse.id ?? "",
            notes: [],
            fileLocation: "/test/test-folder-id"
        )
        testNote = Note(
            id: "test-note-id",
            userID: "test-user-id",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: testCourse.id ?? "",
            fileLocation: "/test/test-note-id",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        testMCQuestion = MCQuestion(
            id: "test-question-id",
            question: "Test Question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0,
            userID: "test-user-id",
            noteID: "test-note-id",
            attemptCount: 0,
            lastAttemptDate: nil
        )
        mockFirebase.courses = [testCourse]
        mockFirebase.folders = [testFolder]
        mockFirebase.notes = [testNote]
        mockFirebase.mcQuestions = [testMCQuestion]
    }

    override func tearDown() {
        mockFirebase = nil
        testCourse = nil
        testFolder = nil
        testNote = nil
        testMCQuestion = nil
        super.tearDown()
    }

    func testGetCourse() {
        let expectation = XCTestExpectation(description: "Get course")
        mockFirebase.getCourse(courseID: testCourse.id ?? "") { course in
            XCTAssertNotNil(course)
            XCTAssertEqual(course?.id, self.testCourse.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetFolder() {
        let expectation = XCTestExpectation(description: "Get folder")
        mockFirebase.getFolder(folderID: testFolder.id ?? "") { folder in
            XCTAssertNotNil(folder)
            XCTAssertEqual(folder?.id, self.testFolder.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetNotesById() {
        let expectation = XCTestExpectation(description: "Get notes by ID")
        mockFirebase.getNotesById(noteIDs: [testNote.id ?? ""]) { notes in
            XCTAssertEqual(notes.count, 1)
            XCTAssertEqual(notes.first?.id, self.testNote.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetFoldersById() {
        let expectation = XCTestExpectation(description: "Get folders by ID")
        mockFirebase.getFoldersById(folderIDs: [testFolder.id ?? ""]) { folders in
            XCTAssertEqual(folders.count, 1)
            XCTAssertEqual(folders.first?.id, self.testFolder.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetIncorrectQuestions() {
        let expectation = XCTestExpectation(description: "Get incorrect questions")
        mockFirebase.getIncorrectQuestions(userID: testMCQuestion.userID ?? "", noteID: testMCQuestion.noteID ?? "") { questions in
            XCTAssertEqual(questions.count, 1)
            XCTAssertEqual(questions.first?.id, self.testMCQuestion.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetCourses() {
        mockFirebase.getCourses()
        XCTAssertEqual(mockFirebase.courses.count, 2)
        XCTAssertEqual(mockFirebase.courses[0].courseName, "Course 1")
        XCTAssertEqual(mockFirebase.courses[1].courseName, "Course 2")
    }

    func testGetNotes() {
        mockFirebase.getNotes()
        XCTAssertEqual(mockFirebase.notes.count, 2)
        XCTAssertEqual(mockFirebase.notes[0].title, "Note 1")
        XCTAssertEqual(mockFirebase.notes[1].title, "Note 2")
    }

    func testGetFolders() {
        let expectation = XCTestExpectation(description: "Get folders")
        mockFirebase.getFolders { folders in
            XCTAssertEqual(folders.count, 2)
            XCTAssertEqual(folders[0].folderName, "Folder 1")
            XCTAssertEqual(folders[1].folderName, "Folder 2")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGetMCQuestions() {
        mockFirebase.getMCQuestions()
        XCTAssertEqual(mockFirebase.mcQuestions.count, 2)
        XCTAssertEqual(mockFirebase.mcQuestions[0].question, "Question 1")
        XCTAssertEqual(mockFirebase.mcQuestions[1].question, "Question 2")
    }

    func testGetNotifications() {
        mockFirebase.getNotifications()
        XCTAssertEqual(mockFirebase.notifications.count, 2)
        XCTAssertEqual(mockFirebase.notifications[0].type, "Type 1")
        XCTAssertEqual(mockFirebase.notifications[0].message, "Message 1")
        XCTAssertEqual(mockFirebase.notifications[1].type, "Type 2")
        XCTAssertEqual(mockFirebase.notifications[1].message, "Message 2")
    }

    func testGetUsers() {
        mockFirebase.getUsers()
        XCTAssertEqual(mockFirebase.users.count, 2)
        XCTAssertEqual(mockFirebase.users[0].name, "User 1")
        XCTAssertEqual(mockFirebase.users[1].name, "User 2")
    }
    
    func testGetFirstUser() {
        let expectation = XCTestExpectation(description: "Get first user")
        
        mockFirebase.getFirstUser { user in
            XCTAssertNotNil(user)
            XCTAssertEqual(user?.name, "Mock User")
            XCTAssertEqual(user?.settings.notificationFrequency, "Daily")
            XCTAssertEqual(user?.streak.currentStreakLength, 0)
            XCTAssertTrue(user?.notifications.isEmpty ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
  func testCreateNote() {
          let expectation = XCTestExpectation(description: "Create note")
          
          mockFirebase.createNote(
              title: "Test Note",
              summary: "Test Summary",
              content: "Test Content",
              course: testCourse
          ) { note, error in
              XCTAssertNil(error)
              XCTAssertNotNil(note)
              XCTAssertTrue(self.mockFirebase.createNoteCalled)
              XCTAssertEqual(self.mockFirebase.notes.count, 2)
              
              XCTAssertEqual(note?.title, "Test Note")
              XCTAssertEqual(note?.summary, "Test Summary")
              XCTAssertEqual(note?.content, "Test Content")
              XCTAssertEqual(note?.courseID, "test-course-id")
              
              expectation.fulfill()
          }
          
          wait(for: [expectation], timeout: 1.0)
      }

    func testCreateNoteWithIDs() {
        let expectation = XCTestExpectation(description: "Create note with IDs")

        Task {
            await mockFirebase.createNoteWithIDs(
                title: "Test Note",
                content: "Test Content",
                images: [],
                courseID: testCourse.id ?? "",
                folderID: testFolder.id,
                userID: testCourse.userID
            ) { note in
                XCTAssertNil(self.mockFirebase.lastError)
                XCTAssertNotNil(note)
                XCTAssertTrue(self.mockFirebase.createNoteCalled)
                XCTAssertEqual(self.mockFirebase.notes.count, 2)

                XCTAssertEqual(note?.title, "Test Note")
                XCTAssertEqual(note?.content, "Test Content")
                XCTAssertEqual(note?.courseID, "test-course-id")
                XCTAssertEqual(note?.fileLocation, "test-course-id/test-folder-id")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
  
  func testGetMostRecentlyUpdatedNotes() {
         // Create some test notes with different dates
         let oldNote = Note(
             id: "old",
             userID: testCourse.userID,
             title: "Old Note",
             summary: "Summary",
             content: "Content",
             images: [],
             createdAt: Date().addingTimeInterval(-86400), // 1 day ago
             courseID: testCourse.id,
             fileLocation: "",
             lastAccessed: Date().addingTimeInterval(-86400),
             lastUpdated: Date().addingTimeInterval(-86400)
         )
         
         let newNote = Note(
             id: "new",
             userID: testCourse.userID,
             title: "New Note",
             summary: "Summary",
             content: "Content",
             images: [],
             createdAt: Date(),
             courseID: testCourse.id,
             fileLocation: "",
             lastAccessed: Date(),
             lastUpdated: Date()
         )
         
         mockFirebase.notes = [oldNote, newNote]
         
         let recentNotes = mockFirebase.getMostRecentlyUpdatedNotes(limit: 2)
         XCTAssertEqual(recentNotes.count, 2)
         XCTAssertEqual(recentNotes.first?.id, "new")
         XCTAssertEqual(recentNotes.last?.id, "old")
     }

    func testDeleteImagesSuccess() {
        let expectation = XCTestExpectation(description: "Images deleted successfully")
        let testImagePaths = ["test-image1.jpg", "test-image2.jpg"]

        mockFirebase.deleteImages(imagePaths: testImagePaths) { error in
            XCTAssertNil(error, "Error should be nil")
            XCTAssertTrue(self.mockFirebase.deleteImagesCalled, "deleteImages should be called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testDeleteImagesFailure() {
        let expectation = XCTestExpectation(description: "Image deletion failed")
        let testImagePaths = ["non-existent-image.jpg"]

        mockFirebase.shouldFailOperations = true

        mockFirebase.deleteImages(imagePaths: testImagePaths) { error in
            XCTAssertNotNil(error, "Error should not be nil")
            XCTAssertTrue(self.mockFirebase.deleteImagesCalled, "deleteImages should be called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
