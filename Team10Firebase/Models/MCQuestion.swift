//
//  MCQuestion.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/29/24.
//

import Foundation
import FirebaseFirestore

struct MCQuestion: Codable {
    @DocumentID var id: String?
    var question: String
    var potentialAnswers: [String]
    var correctAnswer: Int
    var userID: String?
    var noteID: String?
    var attemptCount: Int?
    var lastAttemptDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case question
        case potentialAnswers
        case correctAnswer
        case userID
        case noteID
        case attemptCount
        case lastAttemptDate
    }
}
