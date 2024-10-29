//
//  Folder.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Folder: Codable, Identifiable {
    struct RecentNoteSummary: Codable {
        let noteID: UUID
        let title: String
        let summary: String
        let createdAt: Date
    }

    let id: UUID
    let userID: UUID
    let folderName: String
    let courseID: String
    let notes: [String]
    let fileLocation: String
    let recentNoteSummary: RecentNoteSummary?
}
