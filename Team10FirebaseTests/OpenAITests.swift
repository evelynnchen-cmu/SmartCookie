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
            correctAnswer: 0
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
    
    func testGenerateQuizQuestionsWithNotesOnlyScope() async throws {
        // Prepare mock questions
        let mockQuestion = MCQuestion(
            id: "test-id",
            question: "Test question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0
        )
        
        mockOpenAI.mockQuestions = [mockQuestion]
        
        // Test successful question generation with notesOnlyScope
        let questions = try await mockOpenAI.generateQuizQuestions(
            content: "Test content",
            notesOnlyScope: true
        )
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions[0].question, mockQuestion.question)
        
        // Test failure
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: true
            )
            XCTFail("Should have thrown an error")
        } catch {
            // Expected error
        }
    }
    
    func testParseImage() {
        // Test successful image parsing
        let image = UIImage()
        let expectation = self.expectation(description: "Image parsing")
        
        mockOpenAI.parseImage(image) { parsedText in
            XCTAssertEqual(parsedText, "Mock parsed text")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        // Test failure
        mockOpenAI.shouldFail = true
        let failureExpectation = self.expectation(description: "Image parsing failure")
        
        mockOpenAI.parseImage(image) { parsedText in
            XCTAssertNil(parsedText)
            failureExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGenerateQuizQuestionsWithDelay() async throws {
        // Set a small delay
        mockOpenAI.mockDelay = 0.1
        
        let mockQuestion = MCQuestion(
            id: "test-id",
            question: "Test question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0
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

    func testGenerateQuizQuestionsSuccess() async throws {
        // Prepare mock questions
        let mockQuestion = MCQuestion(
            id: "test-id",
            question: "Test question?",
            potentialAnswers: ["A", "B", "C", "D"],
            correctAnswer: 0
        )
        
        mockOpenAI.mockQuestions = [mockQuestion]
        
        // Test successful question generation
        let questions = try await mockOpenAI.generateQuizQuestions(
            content: "Test content",
            notesOnlyScope: false
        )
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions[0].question, mockQuestion.question)
    }
    
    func testGenerateQuizQuestionsFailureInvalidURL() async throws {
        // Test failure due to invalid URL
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: false
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, "")
            XCTAssertEqual((error as NSError).code, -1)
            XCTAssertEqual((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String, "Mock quiz generation error")
        }
    }

    func testGenerateQuizQuestionsFailureInvalidAPIKey() async throws {
        // Test failure due to invalid API key
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: false
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, "")
            XCTAssertEqual((error as NSError).code, -1)
            XCTAssertEqual((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String, "Mock quiz generation error")
        }
    }
    
    func testGenerateQuizQuestionsFailureNon200HTTPResponse() async throws {
        // Test failure due to non-200 HTTP response
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: false
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, "")
            XCTAssertEqual((error as NSError).code, -1)
            XCTAssertEqual((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String, "Mock quiz generation error")
        }
    }

    func testGenerateQuizQuestionsFailureJSONDecodingError() async throws {
        // Test failure due to JSON decoding error
        mockOpenAI.shouldFail = true
        do {
            _ = try await mockOpenAI.generateQuizQuestions(
                content: "Test content",
                notesOnlyScope: false
            )
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual((error as NSError).domain, "")
            XCTAssertEqual((error as NSError).code, -1)
            XCTAssertEqual((error as NSError).userInfo[NSLocalizedDescriptionKey] as? String, "Mock quiz generation error")
        }
    }
}
