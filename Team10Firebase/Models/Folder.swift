

import Foundation
import FirebaseFirestore

struct Folder: Codable, Identifiable, Hashable {
    struct RecentNoteSummary: Codable, Hashable {
        var noteID: String?
        var title: String
        var summary: String
        var createdAt: Date

        enum CodingKeys: String, CodingKey {
            case noteID
            case title
            case summary
            case createdAt
        }
    }

    @DocumentID var id: String?
    var userID: String?
    var folderName: String
    var courseID: String
    var notes: [String]
    var fileLocation: String
    var recentNoteSummary: RecentNoteSummary?

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case folderName
        case courseID
        case notes
        case fileLocation
        case recentNoteSummary
    }

    // Conformance to Hashable
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.id == rhs.id
            && lhs.userID == rhs.userID
            && lhs.folderName == rhs.folderName
            && lhs.courseID == rhs.courseID
            && lhs.notes == rhs.notes
            && lhs.fileLocation == rhs.fileLocation
            && lhs.recentNoteSummary == rhs.recentNoteSummary
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userID)
        hasher.combine(folderName)
        hasher.combine(courseID)
        hasher.combine(notes)
        hasher.combine(fileLocation)
        hasher.combine(recentNoteSummary)
    }
}
