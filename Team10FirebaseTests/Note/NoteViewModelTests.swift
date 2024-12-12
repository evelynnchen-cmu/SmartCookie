//
//  NoteViewModelTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//


import XCTest
@testable import Team10Firebase

final class NoteViewModelTests: BaseTestCase {
    var viewModel: NoteViewModel!
    var testNote: Note!

    override func setUp() {
        super.setUp()
        testNote = Note(
            id: "note1",
            userID: "user1",
            title: "Sample Note",
            summary: "A brief summary",
            content: "Detailed content",
            images: ["image1", "image2"],
            createdAt: Date(),
            courseID: "course1",
            fileLocation: "/test/"
        )
        viewModel = NoteViewModel(note: testNote)
    }

    func testInitialization() {
        XCTAssertEqual(viewModel.note?.id, testNote.id)
        XCTAssertEqual(viewModel.images, [])
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadImagesSuccess() {
        mockFirebase.notes = [testNote]
        viewModel.loadImages()
        XCTAssertTrue(viewModel.isLoading)
        
        // Simulate image loading completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.images.count, self.testNote.images.count)
        }
    }

    func testLoadImagesFailure() {
        mockFirebase.shouldFailOperations = true
        viewModel.loadImages()
        
        XCTAssertTrue(viewModel.isLoading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.errorMessage)
            XCTAssertTrue(self.viewModel.images.isEmpty)
        }
    }
}
