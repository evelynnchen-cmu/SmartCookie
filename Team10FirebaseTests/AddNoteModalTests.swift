//
//  AddNoteModalTests.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/29/24.
//


import XCTest
import SwiftUI
@testable import Team10Firebase

@MainActor
final class AddNoteModalTests: XCTestCase {
    var mockFirebase: MockFirebase!
    var course: Course!
    var folder: Folder?
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        
        course = Course(
            id: "test-course-id",
            userID: "test-user-id",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/test-course/"
        )
        
        folder = Folder(
            id: "test-folder-id",
            userID: "test-user-id",
            folderName: "Test Folder",
            courseID: "test-course-id",
            notes: [],
            fileLocation: "/test-course/test-folder/"
        )
    }
    
    override func tearDown() {
        mockFirebase = nil
        course = nil
        folder = nil
        super.tearDown()
    }
    
    func testNoteCreation() async {
        var wasOnNoteCreatedCalled = false
        
        let note = Note(
            id: "test-note-id",
            userID: "test-user-id",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: course.id,
            fileLocation: "/test/",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        
        mockFirebase.createNote(
            title: note.title,
            summary: note.summary,
            content: note.content,
            course: course,
            folder: folder
        ) { newNote, error in
            if error == nil {
                wasOnNoteCreatedCalled = true
            }
        }
        
        XCTAssertTrue(mockFirebase.createNoteCalled)
        XCTAssertTrue(wasOnNoteCreatedCalled)
        XCTAssertEqual(mockFirebase.notes.count, 1)
    }
    
    func testNoteCreationFailure() async {
        mockFirebase.shouldFailOperations = true
        var wasOnNoteCreatedCalled = false
        mockFirebase.createNote(
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            course: course,
            folder: folder
        ) { _, _ in
            wasOnNoteCreatedCalled = true
        }
      
        XCTAssertTrue(mockFirebase.createNoteCalled)
        XCTAssertEqual(mockFirebase.notes.count, 0)
    }
    
    func testNoteCreationWithEmptyContent() async {
        var wasOnNoteCreatedCalled = false
        let emptyContentNote = Note(
            id: "test-note-id",
            userID: "test-user-id",
            title: "Test Note",
            summary: "Add note content by editing or uploading images/PDFs to generate a summary.",
            content: "",
            images: [],
            createdAt: Date(),
            courseID: course.id,
            fileLocation: "/test/",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
      
        mockFirebase.createNote(
            title: emptyContentNote.title,
            summary: emptyContentNote.summary,
            content: emptyContentNote.content,
            course: course,
            folder: folder
        ) { newNote, error in
            if error == nil {
                wasOnNoteCreatedCalled = true
            }
        }
        
        XCTAssertTrue(mockFirebase.createNoteCalled)
        XCTAssertTrue(wasOnNoteCreatedCalled)
        XCTAssertEqual(mockFirebase.notes.count, 1)
        XCTAssertEqual(mockFirebase.notes.first?.summary, "Add note content by editing or uploading images/PDFs to generate a summary.")
    }
}
