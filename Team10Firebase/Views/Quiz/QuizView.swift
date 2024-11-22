//
//  QuizView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/21/24.
//

import SwiftUI

struct QuizView: View {
    let note: Note
    let noteContent: String
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var questions: [MCQuestion] = []
    @State private var showScore = false
    @State private var correctAnswers = 0
    @State private var isLoadingQuestions = false
    @State private var errorMessage: String?
    
    private let openAI = OpenAI()
    
    init(note: Note, noteContent: String) {
        self.note = note
        self.noteContent = noteContent
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if isLoadingQuestions {
                    VStack {
                        ProgressView("Generating quiz questions...")
                        Text("This might take a few moments")
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !questions.isEmpty {
                    VStack(spacing: 8) {
                        Text("Quiz Time!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Score >80% to earn points!")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .underline()
                    }
                    .padding(.bottom, 20)
                    
                    if !showScore {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Question \(currentQuestionIndex + 1)/\(questions.count)")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            Text(questions[currentQuestionIndex].question)
                                .font(.title3)
                                .padding(.bottom, 16)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(Array(questions[currentQuestionIndex].potentialAnswers.enumerated()), id: \.offset) { index, answer in
                                    Button(action: {
                                        selectedAnswer = index
                                    }) {
                                        HStack(alignment: .top) {
                                            Text("\(["a", "b", "c", "d"][index])) ")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .padding(.top, 2)
                                            
                                            Text(answer)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 20)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedAnswer == index ? Color.blue.opacity(0.1) : Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(selectedAnswer == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .contentShape(Rectangle())
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        if selectedAnswer != nil {
                            Button(action: checkAnswer) {
                                Text(currentQuestionIndex == questions.count - 1 ? "Finish" : "Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding()
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("Quiz Complete!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("You scored \(Int(Double(correctAnswers) / Double(questions.count) * 100))%")
                                .font(.title3)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(white: 0.95))
        }
        .onAppear {
            generateQuestions()
        }
    }
    
    private func generateQuestions() {
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
    
    private func checkAnswer() {
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
}
