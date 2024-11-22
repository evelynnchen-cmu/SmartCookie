//
//  QuizViewModel.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/22/24.
//


//
//  QuizViewModel.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/21/24.
//

import Foundation

class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: Int?
    @Published var questions: [MCQuestion] = []
    @Published var showScore = false
    @Published var correctAnswers = 0
    @Published var isLoadingQuestions = false
    @Published var errorMessage: String?
    
    private let note: Note
    private let noteContent: String
    private let openAI = OpenAI()
    
    init(note: Note, noteContent: String) {
        self.note = note
        self.noteContent = noteContent
    }
    
    func generateQuestions() {
        isLoadingQuestions = true
        errorMessage = nil
        
        Task {
            do {
                let generatedQuestions = try await openAI.generateQuizQuestions(content: noteContent)
                DispatchQueue.main.async {
                    self.questions = generatedQuestions
                    self.isLoadingQuestions = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to generate questions: \(error.localizedDescription)"
                    self.isLoadingQuestions = false
                }
            }
        }
    }
    
    func checkAnswer() {
        if let selected = selectedAnswer {
            if selected == questions[currentQuestionIndex].correctAnswer {
                correctAnswers += 1
            }
            
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
            } else {
                showScore = true
            }
        }
    }
    
    var score: Int {
        Int(Double(correctAnswers) / Double(questions.count) * 100)
    }
}
