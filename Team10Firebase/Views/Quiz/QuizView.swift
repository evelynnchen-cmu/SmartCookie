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
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                } else if !viewModel.questions.isEmpty {
                    QuizHeaderView()
                        .padding(.bottom, 20)
                    
                    if !viewModel.showScore {
                        QuizContentView(viewModel: viewModel)
                    } else {
                        QuizScoreView(viewModel: viewModel)
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

// Loading View
private struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Generating quiz questions...")
            Text("This might take a few moments")
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
}

// Error View
private struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
    }
}

// Quiz Header
private struct QuizHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Quiz Time!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Score >80% to earn points!")
                .font(.subheadline)
                .foregroundColor(.primary)
                .underline()
        }
    }
}

// Quiz Content
private struct QuizContentView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            QuestionView(viewModel: viewModel)
            
            if viewModel.selectedAnswer != nil {
                NextButton(viewModel: viewModel)
                    .padding()
            }
        }
    }
}

// Question View
private struct QuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                .font(.headline)
                .padding(.bottom, 8)
            
            Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                .font(.title3)
                .padding(.bottom, 16)
                .fixedSize(horizontal: false, vertical: true)
            
            AnswerOptionsView(viewModel: viewModel)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

// Answer Options
private struct AnswerOptionsView: View {
    @ObservedObject var viewModel: QuizViewModel
    private let letters = ["a", "b", "c", "d"]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.questions[viewModel.currentQuestionIndex].potentialAnswers.enumerated()), id: \.offset) { index, answer in
                AnswerButton(
                    index: index,
                    answer: answer,
                    isSelected: viewModel.selectedAnswer == index,
                    action: { viewModel.selectedAnswer = index }
                )
            }
        }
    }
}

// Answer Button
private struct AnswerButton: View {
    let index: Int
    let answer: String
    let isSelected: Bool
    let action: () -> Void
    private let letters = ["a", "b", "c", "d"]
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                Text("\(letters[index])) ")
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
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .contentShape(Rectangle())
        }
    }
}

// Next Button
private struct NextButton: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        Button(action: { viewModel.checkAnswer() }) {
            Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish" : "Next")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}

// Quiz Score View
private struct QuizScoreView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quiz Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You scored \(viewModel.score)%")
                .font(.title3)
        }
    }
}
