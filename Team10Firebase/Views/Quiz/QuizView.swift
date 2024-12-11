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
    @State private var streakLength: Int = 0
    @State private var hasCompletedStreakToday: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(note: Note, noteContent: String, firebase: Firebase) {
        self.firebase = firebase
        _viewModel = StateObject(wrappedValue: QuizViewModel(note: note, noteContent: noteContent))
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if viewModel.isLoadingQuestions {
                  LoadingView(
                          hasCompletedStreakToday: hasCompletedStreakToday,
                          streakLength: streakLength
                      )
                        .transition(.opacity)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error)
                } else if !viewModel.questions.isEmpty {
                    QuizHeaderView(hasCompletedStreakToday: hasCompletedStreakToday)
                        .padding(.bottom, 10)
                    
                    if !viewModel.showScore {
                        VStack(spacing: 16) {
                            HStack {
                                Spacer()
                                CookieProgressView(
                                    currentQuestion: viewModel.currentQuestionIndex + 1,
                                    totalQuestions: viewModel.questions.count,
                                    answers: viewModel.questionResults
                                )
                            }
                            .padding(.horizontal)
                            
                            QuestionView(viewModel: viewModel)
                            
                            VStack {
                                if viewModel.selectedAnswer != nil {
                                    NextButton(viewModel: viewModel, userID: userID, firebase: firebase)
                                }
                            }
                            .frame(height: 50)
                            .padding(.top, 35)
                        }
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
                  streakLength = user.streak.currentStreakLength
                  if let lastQuizDate = user.streak.lastQuizCompletedAt {
                      hasCompletedStreakToday = Calendar.current.isDate(lastQuizDate, inSameDayAs: Date())
                  }
                  viewModel.loadQuestionsWithHistory(userID: userID, firebase: firebase)
              }
          }
        }
    }
}

// Cookie Progress View
struct CookieProgressView: View {
   let currentQuestion: Int
   let totalQuestions: Int
   let answers: [Bool]
   
   var body: some View {
       HStack(spacing: 8) {
           ForEach(0..<totalQuestions, id: \.self) { index in
               ZStack {
                   if index < answers.count {
                       if answers[index] {
                           Image(uiImage: UIImage(named: "cookieIcon") ?? UIImage())
                               .resizable()
                               .scaledToFit()
                               .frame(width: 24, height: 24)
                       } else {
                           Circle()
                               .stroke(darkBrown, lineWidth: 2)
                               .frame(width: 24, height: 24)
                               .background(Circle().fill(darkBrown.opacity(0.1)))
                           Image(systemName: "xmark")
                               .foregroundColor(darkBrown)
                               .font(.system(size: 16))
                       }
                   } else {
                       Circle()
                           .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                           .frame(width: 24, height: 24)
                   }
               }
           }
       }
   }
}

// Loading View
private struct LoadingView: View {
    let hasCompletedStreakToday: Bool
    let streakLength: Int
    
    private func cookieOpacity(for index: Int, currentRotation: Double) -> Double {
        let normalizedIndex = Int(currentRotation / 45) % 8
        if index == normalizedIndex {
            return 1.0
        } else if index == (normalizedIndex + 1) % 8 {
            return 0.7
        } else {
            return 0.4
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            TimelineView(.animation(minimumInterval: 0.01)) { timeline in
                ZStack {
                    ForEach(0..<8) { index in
                        Image(uiImage: UIImage(named: "cookieIcon") ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .offset(y: -50)
                            .rotationEffect(.degrees(Double(index) * 45))
                            .opacity(cookieOpacity(
                                for: index,
                                currentRotation: timeline.date.timeIntervalSince1970 * 500
                            ))
                    }
                }
                .frame(width: 120, height: 120)
            }
            
            VStack(spacing: 16) {
                Text("Loading Questions...")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(darkBrown)
                
              if !hasCompletedStreakToday {
                  VStack(spacing: 8) {
                      HStack(spacing: 4) {
                          Text("\(streakLength) day streak")
                              .font(.headline)
                              .foregroundColor(.orange)
                          Image(systemName: "flame.fill")
                              .foregroundColor(.orange)
                      }
                      
                      Text("Score 80% or better to\nextend your streak!")
                          .font(.subheadline)
                          .foregroundColor(darkBrown.opacity(0.8))
                          .multilineTextAlignment(.center)
                          .fixedSize(horizontal: false, vertical: true)
                  }
                  .frame(maxWidth: 200)
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .background(
                      RoundedRectangle(cornerRadius: 12)
                          .fill(Color.orange.opacity(0.1))
                  )
              }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Error View
private struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(darkBrown)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(message)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// Quiz Header
private struct QuizHeaderView: View {
    let hasCompletedStreakToday: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Text("Quiz")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(darkBrown)
                
                Spacer()
                
                Image(uiImage: UIImage(named: "cookieIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

// Question View
private struct QuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(viewModel.currentQuestionIndex + 1)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(darkBlue)
                .padding(.bottom, 4)
            
            Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                .font(.title3)
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
            
            AnswerOptionsView(viewModel: viewModel)
        }
        .padding(.horizontal)
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
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.top, 2)
                
                Text(answer)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : .black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? darkBrown : tan)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(darkBrown, lineWidth: 1)
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
               .foregroundColor(darkBlue)
               .frame(maxWidth: 300)
               .padding()
               .background(.white)
               .overlay(
                   RoundedRectangle(cornerRadius: 12)
                       .stroke(darkBlue, lineWidth: 2)
               )
       }
       .frame(maxWidth: .infinity)
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
                    .foregroundColor(darkBrown)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.score) / 100)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(darkBrown)
                    .rotationEffect(Angle(degrees: 270.0))
                
                VStack {
                    Text("Score")
                        .font(.title3)
                        .foregroundColor(.black)
                    Text("\(viewModel.score)%")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Image(uiImage: UIImage(named: "cookieIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .offset(y: -100)
            }
            .frame(width: 200, height: 200)
            .padding(.bottom, 20)
            
            if previouslyIncorrectCount > 0 {
                Text("Great progress! You correctly answered \(previouslyIncorrectCount) \(previouslyIncorrectCount == 1 ? "question" : "questions") that you previously got wrong.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding()
                    .background(lightBlue.opacity(0.3))
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
