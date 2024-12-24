//
//  NoteViewModelTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//

import XCTest
@testable import Team10Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

final class NoteViewModelTests: BaseTestCase {
    var viewModel: NoteViewModel!
    var testNote: Note!
    var testCourse: Course!
    
    override func setUp() {
        super.setUp()
        testNote = Note(
            id: "test-note-id",
            userID: "user-1",
            title: "Test Note",
            summary: "A test note summary",
            content: "Test content for the note",
            images: ["test-image-path-1", "test-image-path-2"],
            createdAt: Date(),
            courseID: "test-course-id",
            fileLocation: "/path/"
        )
        testCourse = Course(
            id: "test-course-id",
            userID: "user-1",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/path/"
        )
        viewModel = NoteViewModel(note: testNote)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        testNote = nil
        testCourse = nil
    }
    
    func testInitialization() {
        XCTAssertEqual(viewModel.note?.id, testNote.id, "Note ID should be initialized correctly")
        XCTAssertEqual(viewModel.note?.title, testNote.title, "Note title should be initialized correctly")
        XCTAssertEqual(viewModel.note?.content, testNote.content, "Note content should be initialized correctly")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil at initialization")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false at initialization")
    }
    
    func testLoadImagesSuccess() async {
        let expectation = XCTestExpectation(description: "Images loaded successfully")
        
        // Setup mock data in Firebase Storage before loading images
        let mockStorage = Storage.storage()
        let testData = UIImage(systemName: "photo")?.pngData() ?? Data()
        
        let dispatchGroup = DispatchGroup()
        
        for imagePath in testNote.images ?? [] {
            dispatchGroup.enter()
            let imageRef = mockStorage.reference().child(imagePath)
            imageRef.putData(testData, metadata: nil) { _, _ in
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.viewModel.loadImages()
            
            // Check results after a delay to allow for async operations
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                XCTAssertTrue(self.viewModel.images.count > 0, "Images should be loaded")
                XCTAssertEqual(self.viewModel.images.count, 2, "Two images should be loaded")
                XCTAssertNil(self.viewModel.errorMessage, "Error message should be nil on success")
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testLoadImagesFailure() async {
        let expectation = XCTestExpectation(description: "Image loading failed")
        
        testNote.images = ["invalid-path"]
        viewModel = NoteViewModel(note: testNote)
        viewModel.loadImages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.viewModel.images.isEmpty, "Images should not be loaded on failure")
            XCTAssertNotNil(self.viewModel.errorMessage, "Error message should be set on failure")
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be false after failure")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testCourseFetchOnInitialization() async throws {
        let expectation = XCTestExpectation(description: "Course fetch completed")
        
        // Create the test course using Firebase
        let firebase = Firebase()
        
        // We'll use a completion handler pattern since createCourse uses callbacks
        let courseCreationExpectation = XCTestExpectation(description: "Course creation")
        try await firebase.createCourse(courseName: "Test Course")
        
        // Wait for course creation and get courses
        try await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds for course creation
        
        firebase.getCourses() // This will populate firebase.courses
        
        // Wait another second for courses to be fetched
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard let createdCourse = firebase.courses.first(where: { $0.courseName == "Test Course" }) else {
            XCTFail("Could not find created course")
            return
        }
        
        // Update the test note with the actual course ID
        testNote = Note(
            id: "test-note-id",
            userID: "user-1",
            title: "Test Note",
            summary: "A test note summary",
            content: "Test content for the note",
            images: ["test-image-path-1", "test-image-path-2"],
            createdAt: Date(),
            courseID: createdCourse.id ?? "",
            fileLocation: "/path/"
        )
        
        viewModel = NoteViewModel(note: testNote)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertNotNil(self.viewModel.course, "Course should be fetched during NoteViewModel initialization")
            XCTAssertEqual(self.viewModel.course?.id, createdCourse.id, "Fetched course ID should match the created course ID")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
