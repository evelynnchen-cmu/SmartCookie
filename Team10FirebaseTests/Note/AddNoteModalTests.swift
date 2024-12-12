//
//  AddNoteModalTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//

import XCTest
@testable import Team10Firebase

final class AddNoteModalTests: BaseTestCase {
    var firebase: Firebase!
    var testCourse: Course!

    override func setUp() {
        super.setUp()
        firebase = Firebase()

        // Set up a test course in Firebase
        testCourse = Course(
            id: "test-course-id",
            userID: "user-1",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/"
        )

        let expectation = XCTestExpectation(description: "Test course created in Firebase")
        Task {
            do {
                try await firebase.createCourse(courseName: testCourse.courseName)
                expectation.fulfill()
            } catch {
                XCTFail("Failed to create test course: \(error.localizedDescription)")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    override func tearDown() {
        super.tearDown()

        // Clean up the test course from Firebase
        let expectation = XCTestExpectation(description: "Test course deleted from Firebase")
        firebase.deleteCourse(courseID: testCourse.id ?? "") { error in
            XCTAssertNil(error, "Failed to delete test course from Firebase")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testNoteCreationDisabledWhenTitleEmpty() {
        var testTitle = ""
        var testContent = ""
        let modal = AddNoteModal(
            onNoteCreated: {},
            firebase: firebase,
            course: testCourse,
            testTitle: $testTitle,
            testContent: $testContent
        )

        XCTAssertTrue(testTitle.titleIsDisabled.isFalse, "Fine")
    }

    func testCreateNoteSuccess() {
        let expectation = XCTestExpectation(description: "Note created successfully")
        let modal = AddNoteModal(
            onNoteCreated: { expectation.fulfill() },
            firebase: firebase,
            course: testCourse
        )

        // Simulate user input
        modal.title = "Test Note"
        modal.content = "Test Content"

        modal.testableCreateNote()

        // Validate note creation in Firebase
        firebase.getNotes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let createdNote = self.firebase.notes.first(where: { $0.title == "Test Note" && $0.content == "Test Content" })
            XCTAssertNotNil(createdNote, "The note was not created in Firebase")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
