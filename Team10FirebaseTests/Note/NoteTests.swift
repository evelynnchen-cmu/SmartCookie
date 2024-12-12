//
//  NoteTests.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/12/24.
//


import XCTest
@testable import Team10Firebase

final class NoteTests: BaseTestCase {
    func testNoteInitialization() {
        let note = Note(
            id: "test-id",
            userID: "test-user",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: ["path1", "path2"],
            createdAt: Date(),
            courseID: "course-id",
            fileLocation: "/test/"
        )
        
        XCTAssertEqual(note.id, "test-id")
        XCTAssertEqual(note.userID, "test-user")
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.summary, "Test Summary")
        XCTAssertEqual(note.images, ["path1", "path2"])
    }
    
    func testNoteEquality() {
        let date = Date()
        let note1 = Note(
            id: "id1",
            userID: "user1",
            title: "Title",
            summary: "Summary",
            content: "Content",
            images: [],
            createdAt: date,
            courseID: "course1",
            fileLocation: "/path/"
        )
        let note2 = note1
        let note3 = Note(
            id: "id3",
            userID: "user3",
            title: "Other Title",
            summary: "Other Summary",
            content: "Other Content",
            images: ["image1"],
            createdAt: Date(),
            courseID: "course2",
            fileLocation: "/other/"
        )
        
        XCTAssertEqual(note1, note2)
        XCTAssertNotEqual(note1, note3)
    }
}
