import XCTest
@testable import Team10Firebase
import FirebaseStorage

class FirebaseStorageTests: XCTestCase {
    var firebaseStorage: FirebaseStorage!
    var mockStorage: Storage!
    var mockStorageReference: StorageReference!

    override func setUp() {
        super.setUp()
        firebaseStorage = FirebaseStorage()
        mockStorage = Storage.storage()
        mockStorageReference = mockStorage.reference()
    }

    override func tearDown() {
        firebaseStorage = nil
        mockStorage = nil
        mockStorageReference = nil
        super.tearDown()
    }

    func testUploadImageToFirebaseSuccess() {
        let expectation = XCTestExpectation(description: "Image uploaded successfully")
        let testImage = UIImage(systemName: "photo")!

        firebaseStorage.uploadImageToFirebase(testImage) { filePath in
            XCTAssertNotNil(filePath, "File path should not be nil")
            XCTAssertTrue(filePath!.hasSuffix(".jpg"), "File path should end with .jpg")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testUploadImageToFirebaseFailure() {
        let expectation = XCTestExpectation(description: "Image upload failed")
        let testImage = UIImage()

        firebaseStorage.uploadImageToFirebase(testImage) { filePath in
            XCTAssertNil(filePath, "File path should be nil")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

//    func testDeleteImageSuccess() {
//        let expectation = XCTestExpectation(description: "Image deleted successfully")
//        let testImagePath = "test-image.jpg"
//
//        firebaseStorage.deleteImage(imagePath: testImagePath) { error in
//            XCTAssertNil(error, "Error should be nil")
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 5.0)
//    }
//
//    func testDeleteImageFailure() {
//        let expectation = XCTestExpectation(description: "Image deletion failed")
//        let testImagePath = "non-existent-image.jpg"
//
//        firebaseStorage.deleteImage(imagePath: testImagePath) { error in
//            XCTAssertNotNil(error, "Error should not be nil")
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 5.0)
//    }
}
