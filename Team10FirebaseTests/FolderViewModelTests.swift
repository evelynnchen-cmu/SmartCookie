//
//  FolderViewModelTests.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/12/24.
//


import XCTest
@testable import Team10Firebase
import FirebaseFirestore
import Combine

final class FolderViewModelTests: XCTestCase {
    var sut: FolderViewModel!
    var mockFirebase: MockFirebase!
    var mockFolder: Folder!
    var mockCourse: Course!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        setupInitialState()
        cancellables = Set<AnyCancellable>()
    }
    
    private func setupInitialState() {
        mockFirebase.notes = []
        mockFolder = Folder(
            id: "folder1",
            userID: "user1",
            folderName: "Test Folder",
            courseID: "course1",
            notes: ["note1", "note2"],
            fileLocation: "/test/",
            recentNoteSummary: nil
        )
        mockCourse = Course(
            id: "course1",
            userID: "user1",
            courseName: "Test Course",
            folders: ["folder1"],
            notes: [],
            fileLocation: "/test/"
        )
    }
    
    override func tearDown() {
        sut = nil
        mockFirebase = nil
        mockFolder = nil
        mockCourse = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInit() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        
        XCTAssertEqual(sut.folder.id, mockFolder.id)
        XCTAssertEqual(sut.course.id, mockCourse.id)
        XCTAssertEqual(sut.notes.count, 0)
    }
    
    func testFetchNotes() {
        let mockNotes = [
            Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
        ]
        mockFirebase.notes = mockNotes
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        
        sut.fetchNotes()
        
        XCTAssertEqual(sut.notes.count, 2)
        XCTAssertTrue(sut.notes.allSatisfy { $0.courseID == mockCourse.id })
        XCTAssertTrue(sut.notes.allSatisfy { mockFolder.notes.contains($0.id ?? "") })
    }
    
    func testFetchNotesWithEmptyFolder() {
        mockFolder.notes = []
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        
        sut.fetchNotes()
        
        XCTAssertEqual(sut.notes.count, 0)
    }
    
    func testFetchNotesWithFailure() {
        mockFirebase.shouldFailOperations = true
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 0)
    }
    
    func testUpdateFolderNotes() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        let updatedFolder = Folder(
            id: "folder1",
            userID: "user1",
            folderName: "Updated Folder",
            courseID: "course1",
            notes: ["note1", "note2", "note3"],
            fileLocation: "/test/",
            recentNoteSummary: nil
        )
        mockFirebase.folders = [updatedFolder]
        let expectation = XCTestExpectation(description: "Folder update")
        sut.$folder
            .dropFirst()
            .sink { folder in
                XCTAssertEqual(folder.folderName, "Updated Folder")
                XCTAssertEqual(folder.notes.count, 3)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        sut.updateFolderNotes()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateFolderNotesWithDelay() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        mockFirebase.mockDelay = 0.5
        let expectation = XCTestExpectation(description: "Delayed folder update")
        sut.updateFolderNotes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.folder.id, self.mockFolder.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
  
  
  func testFetchNotesByIDs() {
          let mockNotes = [
              Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
              Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
          ]
          mockFirebase.notes = mockNotes
          let expectation = XCTestExpectation(description: "Fetch notes by IDs")
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              XCTAssertEqual(self.sut.notes.count, 2)
              XCTAssertEqual(self.sut.notes.map { $0.id }, ["note1", "note2"])
              expectation.fulfill()
          }
          
          wait(for: [expectation], timeout: 1.0)
      }
      
      func testFetchNotesByIDsWithInvalidIDs() {
          mockFolder.notes = ["invalid1", "invalid2"]
          let mockNotes = [
              Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
          ]
          mockFirebase.notes = mockNotes
          let expectation = XCTestExpectation(description: "Fetch notes with invalid IDs")
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              XCTAssertEqual(self.sut.notes.count, 0)
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 1.0)
      }
      
      func testUpdateFolderNotesWithNilResponse() {
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          mockFirebase.folders = []
          let originalFolderName = mockFolder.folderName
          let expectation = XCTestExpectation(description: "Update folder with nil response")
          sut.updateFolderNotes()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              XCTAssertEqual(self.sut.folder.folderName, originalFolderName)
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 1.0)
      }
      
      func testFetchNotesWithInvalidCourseID() {
          let mockNotes = [
              Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "wrongCourse", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
              Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "wrongCourse", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
          ]
          mockFirebase.notes = mockNotes
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          sut.fetchNotes()
          XCTAssertEqual(sut.notes.count, 0)
      }
      
      func testFetchNotesWithMixedCourseIDs() {
          let mockNotes = [
              Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
              Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "wrongCourse", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
          ]
          mockFirebase.notes = mockNotes
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          sut.fetchNotes()
          XCTAssertEqual(sut.notes.count, 1)
          XCTAssertEqual(sut.notes.first?.id, "note1")
      }
      
      func testConcurrentFolderUpdates() {
          sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
          let expectation1 = XCTestExpectation(description: "First update")
          let expectation2 = XCTestExpectation(description: "Second update")
          let updatedFolder1 = Folder(
              id: "folder1",
              userID: "user1",
              folderName: "Updated Folder 1",
              courseID: "course1",
              notes: ["note1"],
              fileLocation: "/test/",
              recentNoteSummary: nil
          )
          let updatedFolder2 = Folder(
              id: "folder1",
              userID: "user1",
              folderName: "Updated Folder 2",
              courseID: "course1",
              notes: ["note1", "note2"],
              fileLocation: "/test/",
              recentNoteSummary: nil
          )
          mockFirebase.folders = [updatedFolder1]
          sut.updateFolderNotes()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              self.mockFirebase.folders = [updatedFolder2]
              self.sut.updateFolderNotes()
              expectation1.fulfill()
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              XCTAssertEqual(self.sut.folder.folderName, "Updated Folder 2")
              XCTAssertEqual(self.sut.folder.notes.count, 2)
              expectation2.fulfill()
          }
          wait(for: [expectation1, expectation2], timeout: 1.0)
      }
  
  func testUpdateFolderNotesWithEmptyFolderID() {
          let folderWithoutID = Folder(
              id: nil,
              userID: "user1",
              folderName: "Test Folder",
              courseID: "course1",
              notes: [],
              fileLocation: "/test/",
              recentNoteSummary: nil
          )
          sut = FolderViewModel(firebase: mockFirebase, folder: folderWithoutID, course: mockCourse)
          let expectation = XCTestExpectation(description: "Update folder with empty ID")
          sut.updateFolderNotes()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              XCTAssertEqual(self.sut.folder.folderName, folderWithoutID.folderName)
              expectation.fulfill()
          }
          wait(for: [expectation], timeout: 1.0)
      }
      
    func testFetchNotesWithNilCourseID() {
        let courseWithoutID = Course(
            id: nil,
            userID: "user1",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/test/"
        )
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: courseWithoutID)
        sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 0)
    }
    
    func testFetchNotesByIDsWithEmptyNoteIDsArray() {
        mockFolder.notes = []
        let expectation = XCTestExpectation(description: "Fetch with empty note IDs")
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.sut.notes.count, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
      
    func testCancellablesCleanup() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        sut = nil
        XCTAssertNil(sut)
    }
      
    func testMultipleConsecutiveUpdates() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        let expectation = XCTestExpectation(description: "Multiple updates")
        expectation.expectedFulfillmentCount = 3
        for i in 1...3 {
            let updatedFolder = Folder(
                id: "folder1",
                userID: "user1",
                folderName: "Updated Folder \(i)",
                courseID: "course1",
                notes: Array(repeating: "note", count: i),
                fileLocation: "/test/",
                recentNoteSummary: nil
            )
            mockFirebase.folders = [updatedFolder]
            sut.updateFolderNotes()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(sut.folder.folderName, "Updated Folder 3")
        XCTAssertEqual(sut.folder.notes.count, 3)
    }
      
    func testInitialStateAfterInit() {
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        XCTAssertNotNil(sut.folder)
        XCTAssertNotNil(sut.course)
        XCTAssertEqual(sut.notes.count, 0)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.folder.id)
        XCTAssertNotNil(sut.course.id)
    }
  
  
  func testFetchNotesWithNilNoteIDs() {

      let mockNotes = [
          Note(id: nil, userID: "user1", title: "Note 1", summary: "", content: "", images: [],
               createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(),
               lastUpdated: Date()),
          Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [],
               createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(),
               lastUpdated: Date())
      ]
      mockFirebase.notes = mockNotes
      mockFolder.notes = ["", "note2"]
      sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
      sut.fetchNotes()
      XCTAssertEqual(sut.notes.count, 2)
      if let firstNote = sut.notes.first {
        
          XCTAssertEqual(firstNote.id ?? "", "")
      }
      if let secondNote = sut.notes.last {
          XCTAssertEqual(secondNote.id, "note2")
      }
  }
      
    func testFetchNotesWithEmptyNoteID() {
        let mockNotes = [
            Note(id: "", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
        ]
        mockFirebase.notes = mockNotes
        mockFolder.notes = [""]
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 1)
        XCTAssertEqual(sut.notes.first?.id, "")
    }
      
    func testFetchNotesFilterBooleanComparison() {
        let mockNotes = [
            Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
        ]
        mockFirebase.notes = mockNotes
        mockFolder.notes = ["note1"]
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 1)
        XCTAssertEqual(sut.notes.first?.id, "note1")
    }
      
    func testFetchNotesWithBothCourseAndNoteIDFiltering() {
        let mockNotes = [
            Note(id: "note1", userID: "user1", title: "Note 1", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note2", userID: "user1", title: "Note 2", summary: "", content: "", images: [], createdAt: Date(), courseID: "wrongCourse", fileLocation: "", lastAccessed: Date(), lastUpdated: Date()),
            Note(id: "note3", userID: "user1", title: "Note 3", summary: "", content: "", images: [], createdAt: Date(), courseID: "course1", fileLocation: "", lastAccessed: Date(), lastUpdated: Date())
        ]
        mockFirebase.notes = mockNotes
        mockFolder.notes = ["note1", "note2"]
        sut = FolderViewModel(firebase: mockFirebase, folder: mockFolder, course: mockCourse)
        sut.fetchNotes()
        XCTAssertEqual(sut.notes.count, 1)
        XCTAssertEqual(sut.notes.first?.id, "note1")
    }
}
