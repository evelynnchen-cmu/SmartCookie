//
//  Notification.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Notification: Codable, Identifiable {
    @DocumentID var id: String?
    var type: String
    var scheduledAt: Date
    var message: String
    var quizID: String?
    var userID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case scheduledAt
        case message
        case quizID
        case userID
    }
}
