//
//  SuggestedMessagesView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/10/24.
//
import Foundation
import SwiftUI


struct SuggestedMessagesView: View {
    @Binding var userInput: String
    @Binding var suggestedMessages: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestedMessages, id: \.self) { suggestion in
                    Button(action: {
                        // Toggle selection
                        if userInput == suggestion {
                            userInput = "" // Deselect if already selected
                        } else {
                            userInput = suggestion // Select the prompt
                        }
                    }) {
                        Text(suggestion)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(buttonBackground(for: suggestion))
                            .foregroundColor(userInput == suggestion ? .black : darkBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.top, 10)
            .background(Color.white)
        }
    }

    private func buttonBackground(for suggestion: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(userInput == suggestion ? darkBlue : lightBlue, lineWidth: 2)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(userInput == suggestion ? lightBlue : lightBlue.opacity(0.2))
            )
    }
}
