//
//  QuizTests.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 12/12/24.
//


import XCTest
@testable import Team10Firebase

class QuizTests: XCTestCase {
    var viewModel: QuizViewModel!
    var mockFirebase: Firebase!
    var mockOpenAI: MockOpenAI!
    var testNote: Note!
    let testUserId = "test-user-id"
    
    override func setUp() {
        super.setUp()
        mockFirebase = Firebase()
        mockOpenAI = MockOpenAI()
        testNote = Note(
            id: "test-note-id",
            userID: testUserId,
            title: "Test Note",
            summary: "Test Summary",
            content: "Test Content",
            images: [],
            createdAt: Date(),
            courseID: "test-course-id",
            fileLocation: "/"
        )
        viewModel = QuizViewModel(note: testNote, noteContent: testNote.content)
    }
    
    override func tearDown() {
        viewModel = nil
        mockFirebase = nil
        mockOpenAI = nil
        testNote = nil
        super.tearDown()
    }
  
    func testGenerateQuestions() async throws {
        mockOpenAI.mockQuestions = createMockQuestions(count: 5)
        viewModel.generateQuestions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.questions.count, 5)
            XCTAssertFalse(self.viewModel.isLoadingQuestions)
            XCTAssertNil(self.viewModel.errorMessage)
        }
    }
    
    func testGenerateQuestionsErrorHandling() async throws {
        mockOpenAI.shouldFail = true
        viewModel.generateQuestions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNotNil(self.viewModel.errorMessage)
            XCTAssertFalse(self.viewModel.isLoadingQuestions)
        }
    }
    
    func testGenerateAdditionalQuestions() async throws {
        mockOpenAI.mockQuestions = createMockQuestions(count: 3)
        let additionalQuestions = try await viewModel.generateAdditionalQuestions(neededCount: 3)
        
        XCTAssertEqual(additionalQuestions.count, 3)
    }
    
    func testLoadQuestionsWithHistory() async throws {
        mockFirebase.mcQuestions = createMockQuestions(count: 2)
        viewModel.loadQuestionsWithHistory(userID: testUserId, firebase: mockFirebase)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.viewModel.questions.count, 5)
            XCTAssertFalse(self.viewModel.isLoadingQuestions)
            XCTAssertNil(self.viewModel.errorMessage)
        }
    }
    
    
      func testLoadQuestionsWithEmptyHistory() async throws {
          mockFirebase.mcQuestions = []
          viewModel.loadQuestionsWithHistory(userID: testUserId, firebase: mockFirebase)
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              XCTAssertEqual(self.viewModel.questions.count, 0)
              XCTAssertFalse(self.viewModel.isLoadingQuestions)
              XCTAssertNil(self.viewModel.errorMessage)
          }
      }
    
    


      func testCheckAnswerWithPersistenceCorrect() async throws {
          let expectation = XCTestExpectation(description: "Check correct answer")
          let questions = createMockQuestions(count: 1)
          viewModel.questions = questions
          viewModel.selectedAnswer = 0
        
          viewModel.checkAnswerWithPersistence(userID: testUserId, firebase: mockFirebase)
        
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              XCTAssertEqual(self.viewModel.correctAnswers, 1)
              XCTAssertEqual(self.viewModel.questionResults, [true])
              XCTAssertTrue(self.viewModel.showScore)
              XCTAssertTrue(self.mockFirebase.mcQuestions.isEmpty)
              expectation.fulfill()
          }
          
          await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    private func createMockQuestions(count: Int, startIndex: Int = 0) -> [MCQuestion] {
        return (startIndex..<(startIndex + count)).map { i in
            MCQuestion(
                id: "q\(i)",
                question: "Question \(i)",
                potentialAnswers: ["A", "B", "C", "D"],
                correctAnswer: 0,
                userID: testUserId,
                noteID: testNote.id,
                attemptCount: nil,
                lastAttemptDate: nil
            )
        }
    }
}
