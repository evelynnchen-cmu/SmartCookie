import Foundation
import FirebaseFirestore
import FirebaseStorage
@testable import Team10Firebase

class MockFirebaseCourse: Firebase {
    var shouldFailOperations = false
    var lastError: Error? = nil
    var mockDelay: TimeInterval = 0

    override func createCourse(courseName: String) async throws {
        if shouldFailOperations {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock createCourse error"])
        }
        // Mock implementation
        let course = Course(
            id: UUID().uuidString,
            userID: "mock-user-id",
            courseName: courseName,
            folders: [],
            notes: [],
            fileLocation: "/\(courseName)/"
        )
        self.courses.append(course)
    }

    override func getCourses() {
        if shouldFailOperations {
            lastError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock getCourses error"])
            return
        }
        // Mock implementation
        self.courses = [
            Course(id: "course1", userID: "user1", courseName: "Course 1", folders: [], notes: [], fileLocation: "/course1/"),
            Course(id: "course2", userID: "user2", courseName: "Course 2", folders: [], notes: [], fileLocation: "/course2/")
        ]
    }

    override func updateCourseName(courseID: String, newName: String, completion: @escaping (Error?) -> Void) {
        if shouldFailOperations {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock updateCourseName error"]))
            return
        }
        // Mock implementation
        if let index = self.courses.firstIndex(where: { $0.id == courseID }) {
            self.courses[index].courseName = newName
            completion(nil)
        } else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Course not found"]))
        }
    }

    override func deleteCourse(courseID: String, completion: @escaping (Error?) -> Void) {
        if shouldFailOperations {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock deleteCourse error"]))
            return
        }
        // Mock implementation
        self.courses.removeAll { $0.id == courseID }
        completion(nil)
    }
}