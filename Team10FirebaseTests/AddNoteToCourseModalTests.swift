//
//  AddNoteToCourseModalTests.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/29/24.
//

import XCTest
@testable import Team10Firebase
import SwiftUI

final class AddNoteToCourseModalTests: XCTestCase {
    var mockFirebase: MockFirebase!
    var sampleCourse: Course!
    var sampleFolder: Folder!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        
        sampleCourse = Course(
            id: "test-course-id",
            userID: "test-user-id",
            courseName: "Test Course",
            folders: ["test-folder-id"],
            notes: [],
            fileLocation: "/Test Course/"
        )
        
        sampleFolder = Folder(
            id: "test-folder-id",
            userID: "test-user-id",
            folderName: "Test Folder",
            courseID: "test-course-id",
            notes: [],
            fileLocation: "/Test Course/Test Folder/",
            recentNoteSummary: nil
        )
        
        mockFirebase.courses = [sampleCourse]
        mockFirebase.folders = [sampleFolder]
    }
    
    override func tearDown() {
        mockFirebase = nil
        sampleCourse = nil
        sampleFolder = nil
        super.tearDown()
    }

    func testModalInitialization() {
        let isPresented = Binding.constant(true)
        let completionExpectation = XCTestExpectation(description: "Completion handler called")
        

        let modal = AddNoteToCourseModal(
            isPresented: isPresented,
            firebase: mockFirebase,
            completion: { _, _, _ in
                completionExpectation.fulfill()
            }
        )
        
        XCTAssertNotNil(modal)
    }
    
    
    func testCompletionHandlerExecution() {

        let isPresented = Binding.constant(true)
        let completionExpectation = XCTestExpectation(description: "Completion handler executed")
        var capturedTitle: String?
        var capturedCourse: Course?
        var capturedFolder: Folder?
        
        let modal = AddNoteToCourseModal(
            isPresented: isPresented,
            firebase: mockFirebase,
            completion: { title, course, folder in
                capturedTitle = title
                capturedCourse = course
                capturedFolder = folder
                completionExpectation.fulfill()
            }
        )
        
        modal.completion("Test Note", sampleCourse, sampleFolder)
        
        wait(for: [completionExpectation], timeout: 1.0)
        XCTAssertEqual(capturedTitle, "Test Note")
        XCTAssertEqual(capturedCourse?.id, sampleCourse.id)
        XCTAssertEqual(capturedFolder?.id, sampleFolder.id)
    }
    
    func testMockFirebaseCoursesAvailable() {
        let isPresented = Binding.constant(true)
        
        let modal = AddNoteToCourseModal(
            isPresented: isPresented,
            firebase: mockFirebase,
            completion: { _, _, _ in }
        )
        
        XCTAssertEqual(mockFirebase.courses.count, 1)
        XCTAssertEqual(mockFirebase.courses.first?.courseName, "Test Course")
    }
    
    func testMockFirebaseFoldersAvailable() {

        let isPresented = Binding.constant(true)
        
        let modal = AddNoteToCourseModal(
            isPresented: isPresented,
            firebase: mockFirebase,
            completion: { _, _, _ in }
        )
        
        XCTAssertEqual(mockFirebase.folders.count, 1)
        XCTAssertEqual(mockFirebase.folders.first?.folderName, "Test Folder")
    }
}
