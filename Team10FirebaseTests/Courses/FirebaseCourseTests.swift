import XCTest
@testable import Team10Firebase

class FirebaseCourseTests: XCTestCase {
    var mockFirebase: MockFirebaseCourse!
    var testCourse: Course!

    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCourse()
        testCourse = Course(
            id: "test-course-id",
            userID: "test-user-id",
            courseName: "Test Course",
            folders: [],
            notes: [],
            fileLocation: "/test/"
        )
        mockFirebase.courses = [testCourse]
    }

    override func tearDown() {
        mockFirebase = nil
        testCourse = nil
        super.tearDown()
    }

    func testCreateCourse() async throws {
        let expectation = XCTestExpectation(description: "Create course")
        
        try await mockFirebase.createCourse(courseName: "New Course")
        
        // Wait for the course to be created
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.mockFirebase.courses.count, 2)
            XCTAssertEqual(self.mockFirebase.courses.last?.courseName, "New Course")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testReadCourses() {
        mockFirebase.getCourses()
        
        XCTAssertEqual(mockFirebase.courses.count, 2)
        XCTAssertEqual(mockFirebase.courses.first?.courseName, "Course 1")
    }

    func testUpdateCourse() {
        let expectation = XCTestExpectation(description: "Update course")
        
        mockFirebase.updateCourseName(courseID: testCourse.id ?? "", newName: "Updated Course") { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.mockFirebase.courses.first?.courseName, "Updated Course")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testDeleteCourse() {
        let expectation = XCTestExpectation(description: "Delete course")
        
        mockFirebase.deleteCourse(courseID: testCourse.id ?? "") { error in
            XCTAssertNil(error)
            XCTAssertEqual(self.mockFirebase.courses.count, 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}