//
//  OpenAITests.swift
//  Team10FirebaseTests
//
//  Created by Alanna Cao on 12/11/24.
//


import XCTest
@testable import Team10Firebase

class OpenAITests: XCTestCase {
    var mockOpenAI: MockOpenAI!
    
    override func setUp() {
        super.setUp()
        mockOpenAI = MockOpenAI()
    }
    
    override func tearDown() {
        mockOpenAI = nil
        super.tearDown()
    }
    
    func testSummarizeContent() async throws {
        // Test successful summarization
        mockOpenAI.mockSummary = "Test summary"
        let summary = try await mockOpenAI.summarizeContent(content: "Test content")
        XCTAssertEqual(summary, "Test summary")
        
        // Test failure
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.summarizeContent(content: "Test content")
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
        }
    }
    
    func testGenerateQuizQuestions() async throws {
        // Prepare mock questions
        let mockQuestion = MCQuestion(
            id: "test-id",
            question: "Test question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0,
            userID: nil,
            noteID: nil,
            attemptCount: nil,
            lastAttemptDate: nil
        )
        
        mockOpenAI.mockQuestions = [mockQuestion]
        
        // Test successful question generation
        let questions = try await mockOpenAI.generateQuizQuestions(
            content: "Test content",
            notesOnlyScope: false
        )
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions[0].question, mockQuestion.question)
        
        // Test failure
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: false
            )
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
        }
    }
    
    // Add more test cases
    func testQuizGenerationWithDelay() async throws {
        // Set a small delay
        mockOpenAI.mockDelay = 0.1
        
        let mockQuestion = MCQuestion(
            id: "test-id",
            question: "Test question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0,
            userID: nil,
            noteID: nil,
            attemptCount: nil,
            lastAttemptDate: nil
        )
        
        mockOpenAI.mockQuestions = [mockQuestion]
        
        let startTime = Date()
        let questions = try await mockOpenAI.generateQuizQuestions(
            content: "Test content",
            notesOnlyScope: false
        )
        let timeElapsed = Date().timeIntervalSince(startTime)
        
        XCTAssertEqual(questions.count, 1)
        XCTAssertGreaterThan(timeElapsed, 0.1)
    }
}