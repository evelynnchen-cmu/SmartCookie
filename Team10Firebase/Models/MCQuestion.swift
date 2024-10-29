//
//  MCQuestion.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//

import Foundation

struct MCQuestion: Codable, Identifiable {
    var id: String?
    var question: String
    var potentialAnswers: [String]
    var correctAnswer: Int

    enum CodingKeys: String, CodingKey {
        case id
        case question
        case potentialAnswers
        case correctAnswer
    }
}
