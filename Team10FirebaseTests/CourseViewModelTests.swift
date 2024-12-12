

import XCTest
@testable import Team10Firebase
import FirebaseFirestore
import Combine

class CourseViewModelTests: XCTestCase {
    var sut: CourseViewModel!
    var mockFirebase: MockFirebase!
    var mockCourse: Course!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebase()
        mockCourse = Course(
            id: "test-course-id",
            userID: "test-user-id",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/Test Course/"
        )
        sut = CourseViewModel(firebase: mockFirebase, course: mockCourse)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockFirebase = nil
        mockCourse = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(sut.course.id, mockCourse.id)
        XCTAssertEqual(sut.folders.count, 0)
        XCTAssertEqual(sut.notes.count, 0)
    }
    
  
    func testDeleteNote() {
        let expectation = XCTestExpectation(description: "Delete note")
        let mockNote = Note(
            id: "test-note-id",
            userID: "test-user-id",
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: mockCourse.id,
            fileLocation: "",
            lastAccessed: Date(),
            lastUpdated: Date()
        )
        mockCourse.notes = [mockNote.id!]
        mockFirebase.notes = [mockNote]
        
        sut.$notes
            .dropFirst(2)
            .sink { notes in
                XCTAssertEqual(notes.count, 0)
                XCTAssertTrue(self.mockFirebase.deleteNoteCalled)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.fetchDirectNotes()
        sut.deleteNote(mockNote)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteFolder() {

        let expectation = XCTestExpectation(description: "Delete folder")
        let mockFolder = Folder(
            id: "test-folder-id",
            userID: "test-user-id",
            folderName: "Test Folder",
            courseID: mockCourse.id!,
            notes: [],
            fileLocation: "",
            recentNoteSummary: nil
        )
        mockCourse.folders = [mockFolder.id!]
        mockFirebase.folders = [mockFolder]
        
        sut.$folders
            .dropFirst(2)
            .sink { folders in
                XCTAssertEqual(folders.count, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchFolders()
        sut.deleteFolder(mockFolder)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
