//
//  FirebaseNoteTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//

import XCTest
@testable import Team10Firebase

final class FirebaseNoteTests: XCTestCase {
    var firebase: Firebase!
    var testNote: Note!

    override func setUp() {
        super.setUp()
        firebase = Firebase()
        testNote = Note(
            id: nil,
            userID: "test-user-id",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: nil,
            fileLocation: "/",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
    }

    override func tearDown() {
        firebase = nil
        testNote = nil
        super.tearDown()
    }

    func setupTestEnvironment() async throws -> (Course, Folder) {
        let setupExpectation = XCTestExpectation(description: "Setup test environment")
        var createdCourse: Course?
        var createdFolder: Folder?
        
        try await firebase.createCourse(courseName: "Test Course")
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        firebase.getCourses()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let course = firebase.courses.first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Course not created"])
        }
        createdCourse = course
        
        firebase.createFolder(
            folderName: "Test Folder",
            course: course,
            notes: [],
            fileLocation: ""
        ) { folder, error in
            if let error = error {
                XCTFail("Failed to create folder: \(error.localizedDescription)")
            }
            createdFolder = folder
        }
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let folderFetchExpectation = XCTestExpectation(description: "Fetch folder")
        firebase.getFolders { folders in
            createdFolder = folders.first
            folderFetchExpectation.fulfill()
        }
        await fulfillment(of: [folderFetchExpectation], timeout: 5.0)
        
        guard let folder = createdFolder else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Folder not created"])
        }
        
        setupExpectation.fulfill()
        await fulfillment(of: [setupExpectation], timeout: 10.0)
        
        return (course, folder)
    }

    func testCreateNote() async throws {
        let (course, folder) = try await setupTestEnvironment()
        let expectation = XCTestExpectation(description: "Note created successfully")
        
        firebase.createNote(
            title: testNote.title,
            summary: testNote.summary,
            content: testNote.content,
            images: [],
            course: course,
            folder: folder
        ) { note, error in
            XCTAssertNil(error, "Failed to create note")
            XCTAssertNotNil(note, "Note was not created")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        firebase.getNotes()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        XCTAssertTrue(firebase.notes.contains(where: { $0.title == testNote.title }))
    }

    func testDeleteNote() async throws {
        let (course, folder) = try await setupTestEnvironment()
        
        let createExpectation = XCTestExpectation(description: "Create note")
        let testNoteWithEmptyImages = Note(
            id: nil,
            userID: "test-user-id",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: course.id,
            fileLocation: "/",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        
        firebase.createNote(
            title: testNoteWithEmptyImages.title,
            summary: testNoteWithEmptyImages.summary,
            content: testNoteWithEmptyImages.content,
            images: [],
            course: course,
            folder: folder
        ) { note, error in
            XCTAssertNil(error, "Failed to create note")
            XCTAssertNotNil(note, "Note was not created")
            createExpectation.fulfill()
        }
        
        await fulfillment(of: [createExpectation], timeout: 5.0)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        firebase.getNotes()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        guard let note = firebase.notes.first(where: { $0.title == testNoteWithEmptyImages.title }) else {
            XCTFail("Created note not found")
            return
        }
        
        XCTAssertTrue(note.images.isEmpty, "Note should have no images")
        
        let deleteExpectation = XCTestExpectation(description: "Delete note")
        firebase.deleteNote(note: note, folderID: folder.id) { error in
            XCTAssertNil(error, "Failed to delete note")
            deleteExpectation.fulfill()
        }
        
        await fulfillment(of: [deleteExpectation], timeout: 5.0)
    }
    
    func testUpdateNoteTitle() async throws {
        let (course, folder) = try await setupTestEnvironment()
        
        let createExpectation = XCTestExpectation(description: "Create note")
        firebase.createNote(
            title: testNote.title,
            summary: testNote.summary,
            content: testNote.content,
            images: [],
            course: course,
            folder: folder
        ) { note, error in
            XCTAssertNil(error, "Failed to create note")
            XCTAssertNotNil(note, "Note was not created")
            createExpectation.fulfill()
        }
        
        await fulfillment(of: [createExpectation], timeout: 5.0)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        firebase.getNotes()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        guard let note = firebase.notes.first(where: { $0.title == testNote.title }) else {
            XCTFail("Created note not found")
            return
        }
        
        let updateExpectation = XCTestExpectation(description: "Update note title")
        let newTitle = "Updated Title"
        
        firebase.updateNoteTitle(note: note, newTitle: newTitle) { updatedNote in
            XCTAssertNotNil(updatedNote, "Failed to update note title")
            XCTAssertEqual(updatedNote?.title, newTitle, "Note title was not updated correctly")
            updateExpectation.fulfill()
        }
        
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }

    func testUpdateNoteContent() async throws {
        let (course, folder) = try await setupTestEnvironment()
        
        let createExpectation = XCTestExpectation(description: "Create note")
        firebase.createNote(
            title: testNote.title,
            summary: testNote.summary,
            content: testNote.content,
            images: [],
            course: course,
            folder: folder
        ) { note, error in
            XCTAssertNil(error, "Failed to create note")
            XCTAssertNotNil(note, "Note was not created")
            createExpectation.fulfill()
        }
        
        await fulfillment(of: [createExpectation], timeout: 5.0)
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        firebase.getNotes()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        guard let note = firebase.notes.first(where: { $0.title == testNote.title }) else {
            XCTFail("Created note not found")
            return
        }
        
        let updateExpectation = XCTestExpectation(description: "Update note content")
        let newContent = "Updated Content"
        
        firebase.updateNoteContentCompletion(note: note, newContent: newContent) { updatedNote in
            XCTAssertNotNil(updatedNote, "Failed to update note content")
            XCTAssertEqual(updatedNote?.content, newContent, "Note content was not updated correctly")
            updateExpectation.fulfill()
        }
        
        await fulfillment(of: [updateExpectation], timeout: 5.0)
    }

    func testGetMostRecentlyUpdatedNotes() {
        let note = Note(
            id: "test-id",
            userID: "test-user",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: "test-course",
            fileLocation: "/",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        
        firebase.notes = [note]
        let recentNotes = firebase.getMostRecentlyUpdatedNotes(limit: 1)
        XCTAssertEqual(recentNotes.count, 1, "Failed to fetch most recently updated notes")
        XCTAssertEqual(recentNotes.first?.id, note.id, "Incorrect note fetched")
    }
}
