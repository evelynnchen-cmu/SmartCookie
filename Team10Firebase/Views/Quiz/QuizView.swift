//
//  QuizView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/21/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(note: Note, noteContent: String) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(note: note, noteContent: noteContent))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if viewModel.isLoadingQuestions {
                    VStack {
                        ProgressView("Generating quiz questions...")
                        Text("This might take a few moments")
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !viewModel.questions.isEmpty {
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
                    
                    if !viewModel.showScore {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Question \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                                .font(.headline)
                                .padding(.bottom, 8)
                            
                            Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                                .font(.title3)
                                .padding(.bottom, 16)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.questions[viewModel.currentQuestionIndex].potentialAnswers.enumerated()), id: \.offset) { index, answer in
                                    Button(action: {
                                        viewModel.selectedAnswer = index
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
                                                .fill(viewModel.selectedAnswer == index ? Color.blue.opacity(0.1) : Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(viewModel.selectedAnswer == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
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
                        

                        if viewModel.selectedAnswer != nil {
                            Button(action: viewModel.checkAnswer) {
                                Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish" : "Next")
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
                            
                            Text("You scored \(viewModel.score)%")
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
            viewModel.generateQuestions()
        }
    }
}
