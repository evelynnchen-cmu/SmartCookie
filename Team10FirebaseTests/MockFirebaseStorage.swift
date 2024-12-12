import Foundation
import FirebaseStorage
@testable import Team10Firebase

class MockFirebaseStorage: FirebaseStorage {
    var shouldFail = false
}