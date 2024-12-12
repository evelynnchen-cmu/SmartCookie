//
//  MockOpenAI.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/11/24.
//


@testable import Team10Firebase
import Foundation
import UIKit

class MockOpenAI: OpenAI {
    var shouldFail = false
    var mockSummary = "Mock summary"
    var mockQuestions: [MCQuestion] = []
    var mockDelay: TimeInterval = 0
    
    override func summarizeContent(content: String) async throws -> String {
        if shouldFail {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock summarization error"])
        }
        
        if mockDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        return mockSummary
    }
    
    override func generateQuizQuestions(content: String, notesOnlyScope: Bool = false, numQuestions: Int = 5) async throws -> [MCQuestion] {
        if shouldFail {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock quiz generation error"])
        }
        
        if mockDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        return mockQuestions
    }

    override func parseImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        if shouldFail {
            completion(nil)
            return
        }

        if mockDelay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + mockDelay) {
                completion("Mock parsed text")
            }
        } else {
            completion("Mock parsed text")
        }
    }
}
