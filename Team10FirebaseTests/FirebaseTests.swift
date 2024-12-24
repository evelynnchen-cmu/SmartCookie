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
              XCTAssertEqual(self.mockFirebase.notes.count, 1)
              
              XCTAssertEqual(note?.title, "Test Note")
              XCTAssertEqual(note?.summary, "Test Summary")
              XCTAssertEqual(note?.content, "Test Content")
              XCTAssertEqual(note?.courseID, "test-course-id")
              
              expectation.fulfill()
          }
          
          wait(for: [expectation], timeout: 1.0)
      }
    
  func testGetMostRecentlyUpdatedNotes() {
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
}
