//
//  User.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//

import Foundation

struct User: Codable, Identifiable {
    struct Streak: Codable {
        var currentStreakLength: Int
        var lastQuizCompletedAt: Date?

        enum CodingKeys: String, CodingKey {
            case currentStreakLength
            case lastQuizCompletedAt
        }
    }

    struct Settings: Codable {
        var notificationsEnabled: Bool
        var notificationFrequency: String
        var notesOnlyQuizScope: Bool
        var notesOnlyChatScope: Bool

        enum CodingKeys: String, CodingKey {
            case notificationsEnabled 
            case notificationFrequency
            case notesOnlyQuizScope
            case notesOnlyChatScope 
        }
    }

    struct Quiz: Codable {
        var quizID: String?
        var noteID: String?
        var questions: [String]
        var passed: Bool
        var reattempting: Bool
        var completedAt: Date?

        enum CodingKeys: String, CodingKey {
            case quizID 
            case noteID
            case questions
            case passed
            case reattempting
            case completedAt 
        }
    }

    @DocumentID var id: String?
    var name: String
    var notifications: [String]
    var streak: Streak
    var courses: [String]
    var settings: Settings
    var quizzes: [Quiz]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case notifications
        case streak
        case courses
        case settings
        case quizzes
    }
}