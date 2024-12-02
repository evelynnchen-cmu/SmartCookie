//
//  QuizViewModel.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/22/24.
//

import Foundation
import FirebaseFirestore

class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: Int?
    @Published var questions: [MCQuestion] = []
    @Published var showScore = false
    @Published var correctAnswers = 0
    @Published var isLoadingQuestions = false
    @Published var errorMessage: String?
    @Published var previouslyIncorrectQuestionsCorrectCount: Int = 0
    
    private let note: Note
    private let noteContent: String
    private let openAI = OpenAI()
    private let totalQuestions = 5
    
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
    
    func generateAdditionalQuestions(neededCount: Int) async throws -> [MCQuestion] {
        let generatedQuestions = try await openAI.generateQuizQuestions(content: noteContent)
        // Take only the number of questions we need
        return Array(generatedQuestions.prefix(neededCount))
    }
    
    func loadQuestionsWithHistory(userID: String, firebase: Firebase) {
        isLoadingQuestions = true
        
        firebase.getIncorrectQuestions(userID: userID, noteID: note.id ?? "") { [weak self] incorrectQuestions in
            guard let self = self else { return }
            
            Task {
                do {
                    var allQuestions = incorrectQuestions
                    let additionalQuestionsNeeded = self.totalQuestions - incorrectQuestions.count
                    
                    if additionalQuestionsNeeded > 0 {
                        let newQuestions = try await self.generateAdditionalQuestions(neededCount: additionalQuestionsNeeded)
                        allQuestions.append(contentsOf: newQuestions)
                    }
                    
                    DispatchQueue.main.async {
                        self.questions = allQuestions
                        self.isLoadingQuestions = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to generate additional questions: \(error.localizedDescription)"
                        self.isLoadingQuestions = false
                    }
                }
            }
        }
    }
    
    // saves new incorrect questions, deletes previously-incorrect questions that the user got right, updates attempt count of previously-incorrect questions that the user still got wrong, upserts streak
    func checkAnswerWithPersistence(userID: String, firebase: Firebase) {
        guard let selected = selectedAnswer else { return }
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = selected == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        firebase.handleQuestionResult(
            question: currentQuestion,
            isCorrect: isCorrect,
            userID: userID,
            noteID: note.id ?? ""
        ) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error saving question result: \(error.localizedDescription)"
                }
            }
            
            DispatchQueue.main.async {
                if let self = self {
                    if self.currentQuestionIndex < self.questions.count - 1 {
                        self.currentQuestionIndex += 1
                        self.selectedAnswer = nil
                    } else {
                        self.showScore = true
                      
                      // try to update streak
                      firebase.updateUserStreak(userID: userID, quizScore: self.score) { error in
                          if let error = error {
                              self.errorMessage = "Error updating streak: \(error.localizedDescription)"
                          }
                      }
                    }
                }
            }
        }
      
      if isCorrect && currentQuestion.id != nil {
          previouslyIncorrectQuestionsCorrectCount += 1
      }
    }
    
    var score: Int {
        Int(Double(correctAnswers) / Double(questions.count) * 100)
    }
}
