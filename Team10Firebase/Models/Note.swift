//
//  Note.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Note: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String?
    var title: String
    var summary: String
    var content: String
    var images: [URL]
    var createdAt: Date
    var courseID: String?
    var fileLocation: String
    var lastAccessed: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case title
        case summary
        case content
        case images
        case createdAt
        case courseID
        case fileLocation 
        case lastAccessed
    }
}
