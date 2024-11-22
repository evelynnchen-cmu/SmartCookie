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
  
    var score: Int {
        guard !questions.isEmpty else { return 0 }
        return Int(Double(correctAnswers) / Double(questions.count) * 100)
    }
    
    private let note: Note
    private let noteContent: String
    private let openAI = OpenAI()
    private let firebase = Firebase()
    private var wrongQuestions: [MCQuestion] = []
    
    init(note: Note, noteContent: String) {
        self.note = note
        self.noteContent = noteContent
    }
    
    func generateQuestions() {
        isLoadingQuestions = true
        errorMessage = nil
        
        // First, get any existing wrong questions
        guard let noteID = note.id else {
            self.errorMessage = "Invalid note ID"
            self.isLoadingQuestions = false
            return
        }
        
        firebase.getWrongQuestions(noteID: noteID) { [weak self] wrongQuestions in
            guard let self = self else { return }
            
            Task {
                do {
                    // Calculate how many new questions we need
                    let numNewQuestions = max(5 - wrongQuestions.count, 0)
                    var allQuestions = wrongQuestions
                    
                    if numNewQuestions > 0 {
                        // Generate additional questions if needed
                        let newQuestions = try await self.openAI.generateQuizQuestions(content: self.noteContent, numQuestions: numNewQuestions)
                        allQuestions.append(contentsOf: newQuestions.prefix(numNewQuestions))
                    }
                    
                    // Shuffle the questions to mix wrong and new questions
                    allQuestions.shuffle()
                    
                    DispatchQueue.main.async {
                        self.questions = allQuestions
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
    }
    
    func checkAnswer() {
        if let selected = selectedAnswer {
            let currentQuestion = questions[currentQuestionIndex]
            let isCorrect = selected == currentQuestion.correctAnswer
            
            if !isCorrect {
                // Save wrong question
                guard let noteID = note.id else { return }
                firebase.saveWrongQuestions(noteID: noteID, wrongQuestions: [currentQuestion]) { error in
                    if let error = error {
                        print("Error saving wrong question: \(error.localizedDescription)")
                    }
                }
            }
            
            if isCorrect {
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
}
