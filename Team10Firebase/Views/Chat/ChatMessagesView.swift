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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(messages) { message in
                    HStack(alignment: .bottom, spacing: 12) {
                        if message.isUser {
                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(lightBlue)
                                    .foregroundColor(.black)
                                    .clipShape(BubbleShape(isUser: true))
                                    .offset(y: 25)
                                    .contextMenu {
                                        Button(action: {
                                            selectedMessages.insert(message.id)
                                            isMessageSelectionViewPresented = true
                                        }) {
                                            Label("Save to notes", systemImage: "square.and.arrow.down")
                                        }
                                    }
                            }

                            // User Profile Picture
                            Text("EC")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(darkBlue)
                                .frame(width: 40, height: 40)
                                .background(lightBlue)
                                .clipShape(Circle())
                        } else {
                            // Assistant Profile Picture
                            Image("cookieIcon")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(tan)
                                    .foregroundColor(.black)
                                    .clipShape(BubbleShape(isUser: false))
                                    .offset(y: 25)
                                    .contextMenu {
                                        Button(action: {
                                            selectedMessages.insert(message.id)
                                            isMessageSelectionViewPresented = true
                                        }) {
                                            Label("Save to notes", systemImage: "square.and.arrow.down")
                                        }
                                    }
                            }

                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }

                if isLoading {
                    HStack {
                        Spacer()
                        TypingIndicator()
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
        }
    }
}
