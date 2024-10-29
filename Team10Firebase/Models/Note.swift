//
//  Note.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let title: String
    let summary: String
    let content: String
    let images: [URL]
    let createdAt: Date
    let courseID: UUID
    let fileLocation: String
    let lastAccessed: Date?
}
