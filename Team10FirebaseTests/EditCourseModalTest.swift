//
//  EditCourseModalTest.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/29/24.
//

import XCTest
import SwiftUI
@testable import Team10Firebase

class EditCourseModalTests: XCTestCase {
    var mockFirebase: MockFirebase!
    var sampleCourse: Course!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        sampleCourse = Course(
            id: "test-id",
            userID: "test-user",
            courseName: "Original Course",
            folders: [],
            notes: [],
            fileLocation: "/Original Course/"
        )
        mockFirebase.courses = [sampleCourse]
    }
    
    override func tearDown() {
        mockFirebase = nil
        sampleCourse = nil
        super.tearDown()
    }
    
    func testEditCourseStateInitialization() {
        let editState = EditCourseState()
        XCTAssertNil(editState.courseToEdit)
        XCTAssertFalse(editState.showEditModal)
    }
    
    func testSuccessfulCourseUpdate() async throws {
        let updateExpectation = expectation(description: "Course update")
        let testCourse = sampleCourse!
        mockFirebase.shouldFailOperations = false
        
        let onCourseUpdated = {
            updateExpectation.fulfill()
        }
        _ = EditCourseModal(
            course: testCourse,
            firebase: mockFirebase,
            onCourseUpdated: onCourseUpdated
        )
        mockFirebase.updateCourseName(
            courseID: testCourse.id!,
            newName: "Updated Course"
        ) { _ in
            onCourseUpdated()
        }
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }

    
    func testFailedCourseUpdate() async throws {
        let updateExpectation = expectation(description: "Course update failure")
        
        mockFirebase.shouldFailOperations = true
        let testCourse = sampleCourse!
        
        let onCourseUpdated = {
            updateExpectation.fulfill()
        }
        _ = EditCourseModal(
            course: testCourse,
            firebase: mockFirebase,
            onCourseUpdated: onCourseUpdated
        )
        
        mockFirebase.updateCourseName(
            courseID: testCourse.id!,
            newName: "Updated Course"
        ) { _ in
            onCourseUpdated()
        }
        
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }
    
    func testErrorHandlingWithInvalidCourseID() async throws {
        let updateExpectation = expectation(description: "Invalid course update")
        
        mockFirebase.shouldFailOperations = true
        
        mockFirebase.updateCourseName(
            courseID: "invalid-id",
            newName: "New Name"
        ) { _ in
            updateExpectation.fulfill()
        }
        
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }
}
