//
//  ChatMessagesView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/10/24.
//

import Foundation
import SwiftUI

struct ChatMessagesView: View {
    @Binding var messages: [MessageBubble]
    @Binding var selectedMessages: Set<UUID>
    @Binding var isMessageSelectionViewPresented: Bool
    @Binding var isLoading: Bool
    var notesOnlyChatScope: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ScopeIndicator(notesOnlySetting: notesOnlyChatScope)
                        .padding(.top)

                    ForEach(messages) { message in
                        HStack(alignment: .bottom, spacing: 8) {
                            if message.isUser {
                                Spacer() // Push user message to the right
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(.init(message.content))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(lightBlue)
                                        .foregroundColor(.black)
                                        .clipShape(BubbleShape(isUser: true))
                                        .contextMenu {
                                            Button(action: {
                                                selectedMessages.insert(message.id)
                                                isMessageSelectionViewPresented = true
                                            }) {
                                                Label("Save to notes", systemImage: "square.and.arrow.down")
                                            }
                                            Button(action: {
                                                UIPasteboard.general.string = message.content
                                            }) {
                                                Text("Copy")
                                                Image(systemName: "doc.on.doc")
                                            }
                                        }
                                }
                            } else {
                                Image("cookieIcon")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .offset(y: 20)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(.init(message.content))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(tan)
                                        .foregroundColor(.black)
                                        .clipShape(BubbleShape(isUser: false))
                                        .contextMenu {
                                            Button(action: {
                                                selectedMessages.insert(message.id)
                                                isMessageSelectionViewPresented = true
                                            }) {
                                                Label("Save to notes", systemImage: "square.and.arrow.down")
                                            }
                                            Button(action: {
                                                UIPasteboard.general.string = message.content
                                            }) {
                                                Text("Copy")
                                                Image(systemName: "doc.on.doc")
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if isLoading {
                        HStack(alignment: .bottom, spacing: 8) {
                            Image("cookieIcon")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .offset(y: 20)
                            
                            TypingIndicator()
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                Color.clear
                    .frame(height: 20)
                    .id("bottom")
            }
            .onChange(of: messages) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
        
    }
}
