//
//  Folder.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//

import Foundation
import FirebaseFirestore

struct Folder: Codable, Identifiable {
    struct RecentNoteSummary: Codable {
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
}


