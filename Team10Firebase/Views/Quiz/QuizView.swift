//
//  QuizView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/21/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel: QuizViewModel
    @ObservedObject var firebase: Firebase
    @State private var userID: String = ""
    @Environment(\.dismiss) private var dismiss
    
    init(note: Note, noteContent: String, firebase: Firebase) {
        self.firebase = firebase
        _viewModel = StateObject(wrappedValue: QuizViewModel(note: note, noteContent: noteContent))
    }
    
    var body: some View {
        ZStack {
            Color(white: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if viewModel.isLoadingQuestions {
                    LoadingView()
                        .transition(.opacity)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                } else if !viewModel.questions.isEmpty {
                    QuizHeaderView()
                        .padding(.bottom, 20)
                    
                    if !viewModel.showScore {
                        QuizContentView(viewModel: viewModel, userID: userID, firebase: firebase)
                    } else {
                        QuizScoreView(
                            viewModel: viewModel,
                            previouslyIncorrectCount: viewModel.previouslyIncorrectQuestionsCorrectCount
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            firebase.getFirstUser { user in
                if let user = user {
                    userID = user.id ?? ""
                    viewModel.loadQuestionsWithHistory(userID: userID, firebase: firebase)
                }
            }
        }
    }
}

// Enhanced Loading View with animation
private struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Custom animated loading indicator
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.blue.opacity(0.3))
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 8)
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
            }
            
            VStack(spacing: 12) {
                Text("Preparing Your Quiz")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Loading questions and tracking your progress...")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95))
    }
}

// Error View
private struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
        }
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
    let userID: String
    let firebase: Firebase
    
    var body: some View {
        VStack(spacing: 16) {
            QuestionView(viewModel: viewModel)
            
            if viewModel.selectedAnswer != nil {
                NextButton(viewModel: viewModel, userID: userID, firebase: firebase)
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
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                    .font(.headline)
                
                Spacer()
                
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1),
                           total: Double(viewModel.questions.count))
                    .frame(width: 100)
            }
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
        .shadow(radius: 2)
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
    let userID: String
    let firebase: Firebase
    
    var body: some View {
        Button(action: { viewModel.checkAnswerWithPersistence(userID: userID, firebase: firebase) }) {
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

private struct QuizScoreView: View {
    @ObservedObject var viewModel: QuizViewModel
    let previouslyIncorrectCount: Int
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.score) / 100)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                
                VStack {
                    Text("Score")
                        .font(.title3)
                    Text("\(viewModel.score)%")
                        .font(.system(size: 42, weight: .bold))
                }
            }
            .frame(width: 200, height: 200)
            .padding(.bottom, 20)
            
            if previouslyIncorrectCount > 0 {
                Text("Great progress! You correctly answered \(previouslyIncorrectCount) \(previouslyIncorrectCount == 1 ? "question" : "questions") that you previously got wrong.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
