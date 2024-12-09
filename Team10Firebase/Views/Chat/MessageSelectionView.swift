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

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            Button(action: {
                                if selectedMessages.contains(message.id) {
                                    selectedMessages.remove(message.id)
                                } else {
                                    selectedMessages.insert(message.id)
                                }
                            }) {
                                Image(systemName: selectedMessages.contains(message.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedMessages.contains(message.id) ? .blue : .gray)
                            }
                            
                            if message.isUser {
                                Spacer()
                            }
                            Text(message.content)
                                .foregroundColor(message.isUser ? .white : .black)
                                .padding()
                                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
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
                        .background(selectedMessages.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    isPresented = false
                    selectedMessages.removeAll()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
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
