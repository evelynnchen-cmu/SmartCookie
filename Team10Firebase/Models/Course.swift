//
//  Course.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation
import FirebaseFirestore

struct Course: Codable, Identifiable {
    var id: String?
    var userID: String
    var courseName: String
    var folders: [String]
    var notes: [String]
    var fileLocation: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case courseName
        case folders
        case notes
        case fileLocation
    }
}
