//
//  MCQuestion.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//


import Foundation

struct MCQuestion: Codable, Identifiable {
    let id: UUID
    let question: String
    let potentialAnswers: [String]
    let correctAnswer: Int
}
