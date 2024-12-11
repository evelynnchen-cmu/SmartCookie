//
//  MessageSelectionView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/10/24.
//

import Foundation
import SwiftUI


struct MessageSelectionView: View {
    let messages: [MessageBubble]
    @Binding var selectedMessages: Set<UUID>
    @Binding var isPresented: Bool
    @Binding var isFilePickerPresented: Bool

    var body: some View {
        VStack {
            // Header
            HStack {
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
                                    .foregroundColor(selectedMessages.contains(message.id) ? darkBrown : .gray)
                            }

                            if message.isUser {
                                Spacer()
                            }

                            Text(message.content)
                                .foregroundColor(.primary)
                                .padding()
                                .background(message.isUser ? lightBlue : tan)
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
                        .background(selectedMessages.isEmpty ? Color.gray : mediumBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedMessages.isEmpty)

                Button(action: {
                    isPresented = false
                    selectedMessages.removeAll()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(lightBlue.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(12)
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
