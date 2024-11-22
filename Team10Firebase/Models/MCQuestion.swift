//
//  MCQuestion.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//

import Foundation
import FirebaseFirestore

struct MCQuestion: Codable {
    var question: String
    var potentialAnswers: [String]
    var correctAnswer: Int
}
