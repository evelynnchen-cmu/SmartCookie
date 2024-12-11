//
//  ChatHeaderView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/11/24.
//

import Foundation
import SwiftUI

struct ChatHeaderView: View {
    @Binding var selectedScope: String
    @Binding var isMessageSelectionViewPresented: Bool
    @Binding var isChatViewPresented: Bool?
    @ObservedObject var firebase: Firebase

    var body: some View {
        HStack {
            // Button to save messages
            Button(action: {
                isMessageSelectionViewPresented = true
            }) {
                Image(systemName: "square.and.arrow.down.on.square")
                    .foregroundColor(.black)
            }

            Spacer()

            // Dropdown Menu for Course Selection
            Menu {
                Button(action: {
                    selectedScope = "General"
                }) {
                    Text("General")
                }
                ForEach(firebase.courses, id: \.id) { course in
                    Button(action: {
                        selectedScope = course.id ?? "General"
                    }) {
                        Text(course.courseName)
                    }
                }
            } label: {
                HStack {
                    Text(self.selectedScope == "General" ? "General" : firebase.courses.first { $0.id == self.selectedScope }?.courseName ?? "General")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .foregroundColor(.black)
            }

            Spacer()

            // Button to close the chat view
            if let isPresented = isChatViewPresented {
                Button(action: {
                    isChatViewPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
}
