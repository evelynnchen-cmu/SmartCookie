//
//  MessageSelectionView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/10/24.
//

import Foundation
import SwiftUI

//struct MessageBubble: Identifiable {
//    let id: UUID
//    let content: String
//    let isUser: Bool
//}

struct MessageSelectionView: View {
    let messages: [MessageBubble]
    @Binding var selectedMessages: Set<UUID>
    @Binding var isPresented: Bool
    @Binding var isFilePickerPresented: Bool

    var lightBlue: Color = Color.blue.opacity(0.3) // Replace with your actual `lightBlue` definition if available

    var body: some View {
        VStack {
            // Header
            HStack {
                Image(systemName: "minus")
                    .foregroundColor(.black)
                Spacer()
                Text("Choose to save")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    isPresented = false
                    selectedMessages.removeAll()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            .padding()

            // Message selection list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages, id: \.id) { message in
                        HStack {
                            Button(action: {
                                toggleSelection(for: message.id)
                            }) {
                                Image(systemName: selectedMessages.contains(message.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedMessages.contains(message.id) ? lightBlue : .gray)
                            }

                            if message.isUser {
                                Spacer()
                            }

                            Text(message.content)
                                .foregroundColor(.primary)
                                .padding()
                                .background(message.isUser ? lightBlue : Color.gray.opacity(0.2))
                                .clipShape(BubbleShape(isUser: message.isUser))
                                .onTapGesture {
                                    toggleSelection(for: message.id)
                                }

                            if !message.isUser {
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Save and cancel buttons
            HStack {
                Button(action: {
                    if !selectedMessages.isEmpty {
                        isPresented = false
                        isFilePickerPresented = true
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMessages.isEmpty ? Color.gray : lightBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedMessages.isEmpty)

                Button(action: {
                    isPresented = false
                    selectedMessages.removeAll()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(lightBlue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    private func toggleSelection(for id: UUID) {
        if selectedMessages.contains(id) {
            selectedMessages.remove(id)
        } else {
            selectedMessages.insert(id)
        }
    }
}
