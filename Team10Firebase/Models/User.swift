//
//  User.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct User: Codable, Identifiable {
    struct Streak: Codable {
        let currentStreakLength: Int
        let lastQuizCompletedAt: Date?
    }

    struct Settings: Codable {
        let notificationsEnabled: Bool
        let notificationFrequency: String
        let notesOnlyQuizScope: Bool
        let notesOnlyChatScope: Bool
    }

    struct Quiz: Codable {
        let quizID: UUID
        let noteID: UUID
        let questions: [String]
        let passed: Bool
        let reattempting: Bool
        let completedAt: Date?
    }

    let id: UUID
    let name: String
    let notifications: [String]
    let streak: Streak
    let courses: [String]
    let settings: Settings
    let quizzes: [Quiz]
}
