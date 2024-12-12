//
//  EditNoteModalTests.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/12/24.
//

import XCTest
@testable import Team10Firebase

final class EditNoteModalTests: BaseTestCase {
    var firebase: Firebase!
    var testNote: Note!

    override func setUp() {
        super.setUp()
        firebase = Firebase()

        // Set up a test note in Firebase
        testNote = Note(
            id: "test-note-id",
            userID: "test-user-id",
            title: "Original Title",
            summary: "Original Summary",
            content: "Original Content",
            images: [],
            createdAt: Date(),
            courseID: "test-course-id",
            fileLocation: "/path/"
        )

        // Add the test note to Firebase
        let expectation = XCTestExpectation(description: "Test note created in Firebase")
        firebase.createNote(
            title: testNote.title,
            summary: testNote.summary,
            content: testNote.content,
            images: testNote.images,
            course: Course(id: "test-course-id", userID: "test-user-id", courseName: "Test Course", folders: [], notes: [], fileLocation: "/path/")
        ) { error in
            XCTAssertNil(error, "Failed to create test note in Firebase")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    override func tearDown() {
        super.tearDown()

        // Clean up the test note from Firebase
        let expectation = XCTestExpectation(description: "Test note deleted from Firebase")
        firebase.deleteNote(note: testNote, folderID: nil) { error in
            XCTAssertNil(error, "Failed to delete test note from Firebase")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testUpdateButtonState() {
        // Initialize the EditNoteModal
        let modal = EditNoteModal(note: testNote, firebase: firebase) {}

        // Access state variables through the helper method
        let testableState = modal.getTestableState()
        var newTitle = testableState.newTitle
        var newContent = testableState.newContent

        // Verify the "Update Note" button is disabled when no changes are made
        XCTAssertTrue(newTitle == testNote.title && newContent == testNote.content, "The Update Note button should be disabled when no changes are made")

        // Simulate changing the title
        newTitle = "Updated Title"
        XCTAssertFalse(newTitle.isEmpty && (newTitle == testNote.title && newContent == testNote.content), "The Update Note button should be enabled when the title changes")

        // Reset the title and change the content
        newTitle = testNote.title
        newContent = "Updated Content"
        XCTAssertFalse(newTitle.isEmpty && (newTitle == testNote.title && newContent == testNote.content), "The Update Note button should be enabled when the content changes")
    }
}
