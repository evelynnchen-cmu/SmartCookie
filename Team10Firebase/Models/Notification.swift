//
//  Notification.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation
import FirebaseFirestore

struct Notification: Codable, Identifiable {
    @DocumentID var id: String?
    var type: String
    var message: String
    var quizID: String?
    var scheduledAt: Date
    var userID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case message
        case quizID
        case scheduledAt
        case userID
    }
}
