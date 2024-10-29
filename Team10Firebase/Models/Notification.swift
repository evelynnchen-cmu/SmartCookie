//
//  Notification.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Notification: Codable, Identifiable {
    let id: UUID
    let type: String
    let scheduledAt: Date
    let message: String
    let quizID: UUID?
    let userID: UUID
}
