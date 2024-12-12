//
//  AddNoteModalCourseTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//

import XCTest
@testable import Team10Firebase

final class AddNoteModalCourseTests: BaseTestCase {
    var firebase: Firebase!
    var testCourses: [Course] = []

    override func setUp() {
        super.setUp()
        firebase = Firebase()

        // Set up test courses in Firebase
        let expectation = XCTestExpectation(description: "Test courses created in Firebase")
        let courses = [
            Course(id: "course1", userID: "user1", courseName: "Math", folders: [], notes: [], fileLocation: "/Math/"),
            Course(id: "course2", userID: "user1", courseName: "Science", folders: [], notes: [], fileLocation: "/Science/")
        ]
        let dispatchGroup = DispatchGroup()

        courses.forEach { course in
            dispatchGroup.enter()
            Task {
                do {
                    try await firebase.createCourse(courseName: course.courseName)
                    self.testCourses.append(course)
                } catch {
                    XCTFail("Failed to create test course: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    override func tearDown() {
        super.tearDown()

        // Clean up test courses from Firebase
        let expectation = XCTestExpectation(description: "Test courses deleted from Firebase")
        let dispatchGroup = DispatchGroup()

        testCourses.forEach { course in
            dispatchGroup.enter()
            firebase.deleteCourse(courseID: course.id ?? "") { error in
                XCTAssertNil(error, "Failed to delete test course: \(course.courseName)")
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testCourseSelection() {
        let expectation = XCTestExpectation(description: "Course selection tested successfully")

        // Initialize the modal
        let modal = AddNoteModalCourse(isPresented: .constant(true), firebase: firebase) { title, selectedCourse in
            XCTAssertEqual(title, "Selected Course Title")
            XCTAssertEqual(selectedCourse?.courseName, "Math", "Expected selected course to be 'Math'")
            expectation.fulfill()
        }

        // Simulate course selection
        let testableCourseName = modal.getTestableCourseName()
        XCTAssertEqual(testableCourseName, "Math", "The courseName property should be updated to 'Math'")
        XCTAssertEqual(modal.course?.courseName, "Math", "The selected course should be 'Math'")

        wait(for: [expectation], timeout: 5.0)
    }
}
