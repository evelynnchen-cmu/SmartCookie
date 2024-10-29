//
//  Course.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct Course: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let courseName: String
    let folders: [String]
    let notes: [String]
    let fileLocation: String
}