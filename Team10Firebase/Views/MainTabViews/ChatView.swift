//
//  ChatView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI
import Foundation
struct ChatView: View {
    @State private var messages: [MessageBubble] = []
    @State private var userInput: String = ""
    @State private var isLoading = false
    @State private var messagesHistory: [[String: String]] = []
    @State private var selectedScope: String
    @State private var courseNotes: [Note] = []
    @State private var selectedCourse: Course?
    @State private var selectedFolder: Folder?
    
    @State private var isFilePickerPresented = false
    @State private var selectedNote: Note?
    @State private var selectedMessages: Set<UUID> = []
    @State private var isMessageSelectionViewPresented = false
    @State private var showSaveConfirmation = false
    @State private var saveConfirmationMessage = ""
    @State private var notesOnlyChatScope: Bool = false
    
    @ObservedObject private var firebase = Firebase()
    @Binding var isChatViewPresented: Bool?
  
    // System prompt defining the behavior and tone of the AI.
    @State private var systemPrompt = ""
    
    //  The OpenAI API key loaded from the Secrets.plist file.
    let openAIKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OpenAIKey"] as? String else {
            fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
        }
        return key
    }()
    
  init(selectedCourse: Course? = nil, selectedFolder: Folder? = nil, isChatViewPresented: Binding<Bool?>? = nil) {
    if let isPresented = isChatViewPresented {
      self._isChatViewPresented = isPresented
    }
    else {
      self._isChatViewPresented = .constant(nil)
    }
    if let course = selectedCourse {
      print(course)
      self.selectedCourse = course
      self.selectedScope = course.id ?? "General"
    }
    else {
      print("no course")
      self.selectedScope = "General"
    }
  }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isMessageSelectionViewPresented = true
                    }) {
                        Image(systemName: "square.and.arrow.down.on.square")
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("General") {
                            selectedScope = "General"
                            courseNotes = []
                            clearChat()
                        }
                        ForEach(firebase.courses, id: \.id) { course in
                            Button(course.courseName) {
                                selectedScope = course.id ?? "General"
                                fetchNotes(for: selectedScope)
                                clearChat()
                            }
                        }
                    } label: {
                        HStack {
                          Text(self.selectedScope == "General" ? "General" : firebase.courses.first { $0.id == self.selectedScope }?.courseName ?? "General")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    Spacer()

                  if isChatViewPresented != nil {
                    Button(action: {
                      isChatViewPresented = false
                    }) {
                      Image(systemName: "xmark")
                        .foregroundColor(.black)
                    }
                  }

                }
                .padding()
                
                if messages.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("To save tidbits from this conversation, make sure to add responses to your file before exiting.")
                                .foregroundColor(.gray).opacity(0.7)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                                .padding(.horizontal, 46)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                      
                      ScopeIndicator(notesOnlySetting: notesOnlyChatScope)
                          .padding(.top)
                      
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                }
                                Text(message.content)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .background(
                                        message.isUser ? Color.blue : Color(.systemGray6)
                                    )
                                    .clipShape(BubbleShape(isUser: message.isUser))
                                if !message.isUser {
                                    Spacer()
                                }
                            }
                            .padding(message.isUser ? .leading : .trailing, 60)
                            .padding(.vertical, 4)
                        }
                      if isLoading {
                          HStack {
                              TypingIndicator()
                              Spacer()
                          }
                          .padding(.trailing, 60)
                          .padding(.vertical, 4)
                      }
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Type a message", text: $userInput, axis: .vertical)
                            .lineLimit(1...5)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .gesture(
                                DragGesture(minimumDistance: 30)
                                    .onEnded { value in
                                        if value.translation.height > 100 {
                                            dismissKeyboard()
                                        }
                                    }
                            )
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(userInput.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(userInput.isEmpty || isLoading)
                    }
                    .padding()
                }
                .background(Color.white)
            }
            .sheet(isPresented: $isMessageSelectionViewPresented) {
                MessageSelectionView(
                    messages: messages,
                    selectedMessages: $selectedMessages,
                    isPresented: $isMessageSelectionViewPresented,
                    isFilePickerPresented: $isFilePickerPresented
                )
            }
            .sheet(isPresented: $isFilePickerPresented) {
                FilePickerView(firebase: firebase, isPresented: $isFilePickerPresented, selectedNote: $selectedNote)
                    .onDisappear {
                        if let note = selectedNote {
                            appendMessagesToNoteContent(note: note)
                            saveConfirmationMessage = "Successfully saved \(selectedMessages.count) notes to \(note.id ?? "")/\(note.title)"
                            showSaveConfirmation = true
                        }
                        selectedMessages.removeAll()
                    }
            }
            .onAppear {
                firebase.getCourses()
                firebase.getNotes()
                clearChat()
                            firebase.getFirstUser { user in
                if let user = user {
                    self.notesOnlyChatScope = user.settings.notesOnlyChatScope
                  
                    if user.settings.notesOnlyChatScope {
                        systemPrompt = "You are an expert study assistant who is knowledgeable in any subject matter and can breakdown and explain concepts better than anyone else. Today's date and time are \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short)). You will only converse about topics related to the courses. Do not ask or answer any questions about personal matters or unrelated topics. You will do your best to provide accurate and helpful information to the user. You will ask clarifying questions if need be. You will be concise in your answers and know that your entire message could be saved to notes for later, so don't add any extra fluff. You will always refer to your context and knowledge base first, and cite from the user's courseNotes when possible. You will be encouraging but not too overexcited. You will do this because you care very much about the user's learning and productivity, and your entire objective is to teach the user and assist them with their problems. Additionally, your knowledge base is only the user's notes and what they tell you. You may not supplement with any outside knowledge."
                    } else {
                      systemPrompt = "You are an expert study assistant who is knowledgeable in any subject matter and can breakdown and explain concepts better than anyone else. Today's date and time are \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short)). You will only converse about topics related to the courses. Do not ask or answer any questions about personal matters or unrelated topics. You will do your best to provide accurate and helpful information to the user. You will ask clarifying questions if need be. You will be concise in your answers and know that your entire message could be saved to notes for later, so don't add any extra fluff. You will always refer to your context and knowledge base first, and cite from the user's courseNotes when possible. You will be encouraging but not too overexcited. You will do this because you care very much about the user's learning and productivity, and your entire objective is to teach the user and assist them with their problems."
                    }
                } else {
                    print("Failed to fetch user.")
                }
            }
            }
            .onChange(of: selectedScope) { oldScope, newScope in
                if newScope != "General" {
                    fetchNotes(for: newScope)
                } else {
                    courseNotes = []
                }
                clearChat()
            }
            .alert(isPresented: $showSaveConfirmation) {
                Alert(title: Text("Save Confirmation"), message: Text(saveConfirmationMessage), dismissButton: .default(Text("OK")))
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetChatView)) { _ in
                clearChat()
            }
        }
    }

    private func appendMessagesToNoteContent(note: Note) {
        let selectedMessagesContent = messages.filter { selectedMessages.contains($0.id) }.map { $0.content }.joined(separator: "\n")
        let newContent = note.content + "\n" + selectedMessagesContent
        if let noteID = note.id {
            firebase.updateNoteContent(noteID: noteID, newContent: newContent)
        }
    }
    
    private func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Handles the user's input message, appends it to chat, and sends it to the API.
    func sendMessage() {
        let userMessage = userInput
        messages.append(MessageBubble(content: userMessage, isUser: true, isMarkdown: false))
        userInput = ""
        isLoading = true
        messagesHistory.append(["role": "user", "content": userMessage])

        callChatGPTAPI(with: messagesHistory) { response in
            DispatchQueue.main.async {
                self.messages.append(MessageBubble(content: response, isUser: false, isMarkdown: true))
                self.messagesHistory.append(["role": "assistant", "content": response])
                self.isLoading = false
            }
        }
    }

    // Sends chat history to the API and gets the AI's response.
    // - Parameters:
    // - messagesHistory: The conversation history as an array of role-content pairs. Roles are system (sets up context), user (what the user inputted), and assistant (the AI's response).
    // - completion: Completion handler to receive the AI's response.
    func callChatGPTAPI(with messagesHistory: [[String: String]], completion: @escaping (String) -> Void) {
      guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let notesContent = courseNotes.map { note in
            let formattedDate = DateFormatter.localizedString(from: note.createdAt, dateStyle: .long, timeStyle: .short)
            return ["role": "system", "content": "Title: \(note.title)\nSummary: \(note.summary)\nDate: \(formattedDate)\nContent: \(note.content)"]
        }
        let combinedMessages = notesContent + messagesHistory

        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: combinedMessages.map { Message(role: $0["role"]!, content: [MessageContent(type: "text", text: $0["content"], imageURL: nil)]) },
            maxTokens: 300
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            print("Failed to create JSON payload.")
            completion("Failed to create JSON payload.")
            return
        }

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error.localizedDescription)")
                completion("Failed to connect to the API.")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received")
                completion("No data received from the API.")
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let choice = jsonResponse.choices.first {
                    completion(choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion("Unexpected response format.")
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                completion("Failed to parse API response.")
            }
        }.resume()
    }

    // Fetches notes for a specific course and updates courseNotes.
    // - Parameter courseID: The ID of the course for which to fetch notes.
    func fetchNotes(for courseID: String) {
        courseNotes = firebase.notes.filter { $0.courseID == courseID }
    }

    // Clears the chat view and resets the message history.
    func clearChat() {
        messages.removeAll()
        messagesHistory = [
            ["role": "system", "content": systemPrompt]
        ]
        
        let welcomeMessage: String
        if selectedScope == "General" {
            welcomeMessage = "Hello, you're in the general chat, where you can ask questions about any topic. If you'd like me to reference a specific course's notes, please select a course from the dropdown menu above. Don't forget to save any useful responses to your notes before exiting!"
        } else {
            let courseName = firebase.courses.first(where: { $0.id == selectedScope })?.courseName ?? "selected course"
            let sampleNotes = courseNotes.prefix(3).map { $0.title }.joined(separator: ", ")
            
            welcomeMessage = "Hello, you're in the \(courseName) chat, and I can see your notes including \(sampleNotes). Feel free to ask questions about this course material. Don't forget to save any useful responses to your notes before exiting!"
        }
        
        messages.append(MessageBubble(content: welcomeMessage, isUser: false, isMarkdown: true))
        messagesHistory.append(["role": "assistant", "content": welcomeMessage])
    }
}

struct MessageBubble: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let isMarkdown: Bool
}

struct ScopeIndicator: View {
    var notesOnlySetting: Bool
    
    var body: some View {
      Text("AI Knowledge Limitations: \(notesOnlySetting ? "Notes only" : "None")\nYou can change this in your settings.")
            .multilineTextAlignment(.leading)
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
    }
}
