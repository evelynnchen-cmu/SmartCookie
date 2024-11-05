//
//  ChatView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI
import Foundation
struct ChatView: View {
    @State private var messages: [MessageBubble] = [] // Stores messages in the chat view.
    @State private var userInput: String = "" // Tracks user input from the text field.
    @State private var isLoading = false // Indicates if a request is in progress.
    @State private var messagesHistory: [[String: String]] = [] // Maintains a history of chat messages.
    @State private var selectedScope: String = "General" // Tracks the selected scope (General or a specific course).
    @State private var courseNotes: [Note] = [] // Stores notes for the selected course.
    @State private var selectedCourse: Course?
    @State private var selectedFolder: Folder?
    
    @State private var isFilePickerPresented = false // State variable to control the presentation of the file picker
    @State private var selectedNote: Note? // State variable to store the selected note
    @State private var selectedMessages: Set<UUID> = [] // Track selected messages
    @State private var isSelectingMessages = false // Track if the user is in selection mode
    
    @ObservedObject private var firebase = Firebase()
    
    //  The OpenAI API key loaded from the Secrets.plist file.
    let openAIKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OpenAIKey"] as? String else {
            fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
        }
        return key
    }()
    
    // System prompt defining the behavior and tone of the AI.
    let systemPrompt = "You are an expert study assistant who is knowledgeable in any subject matter and can breakdown and explain concepts better than anyone else. Today's date and time are \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .short)). You will only converse about topics related to the courses. Do not ask or answer any questions about personal matters or unrelated topics. You will do your best to provide accurate and helpful information to the user. You will ask clarifying questions if need be. You will be concise in your answers and know that your entire message could be saved to notes for later, so don't add any extra fluff. You will always refer to your context and knowledge base first, and cite from the user's courseNotes when possible. You will be encouraging but not too overexcited. You will do this because you care very much about the user's learning and productivity, and your entire objective is to teach the user and assist them with their problems."

    var body: some View {
//      Note: VStack needed or else a duplicate tab in AppView is created
        VStack {
        // Scope selection menu
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
                Text(selectedScope == "General" ? "General" : firebase.courses.first { $0.id == selectedScope }?.courseName ?? "General")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
            // Chat scroll view
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages) { message in
                        HStack {
                            if isSelectingMessages {
                                Button(action: {
                                    if selectedMessages.contains(message.id) {
                                        selectedMessages.remove(message.id)
                                    } else {
                                        selectedMessages.insert(message.id)
                                    }
                                }) {
                                    Image(systemName: selectedMessages.contains(message.id) ? "checkmark.circle.fill" : "circle")
                                }
                            }
                            Text(message.content)
                                .padding()
                                .background(message.isUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                        }
                    }
                }
                .padding()
            }
            
            // Message input field and send button
            HStack {
                Button(action: {
                    isSelectingMessages.toggle()
                    if !isSelectingMessages {
                        selectedMessages.removeAll()
                    }
                }) {
                    Text(isSelectingMessages ? "Cancel" : "Select Messages")
                }
                .padding()
                .disabled(messages.isEmpty)
                
                if isSelectingMessages {
                    Button(action: {
                        isFilePickerPresented = true
                    }) {
                        Text("Select Note")
                    }
                    .sheet(isPresented: $isFilePickerPresented) {
                        FilePickerView(firebase: firebase, isPresented: $isFilePickerPresented, selectedNote: $selectedNote)
                            .onDisappear {
                                if let note = selectedNote {
                                    appendMessagesToNoteContent(note: note)
                                }
                            }
                    }
                }
                Spacer()
                TextField("Type a message", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: sendMessage) {
                    Text("Send")
                }
                .disabled(userInput.isEmpty || isLoading)
                .padding()
            }
        }
        .onAppear {
            firebase.getCourses()
            firebase.getNotes()
            clearChat()
        }
        .onChange(of: selectedScope) { oldScope, newScope in
            if newScope != "General" {
                fetchNotes(for: newScope)
            } else {
                courseNotes = []
            }
            clearChat()
        }
    }

    private func appendMessagesToNoteContent(note: Note) {
        let selectedMessagesContent = messages.filter { selectedMessages.contains($0.id) }.map { $0.content }.joined(separator: "\n")
        let newContent = note.content + "\n" + selectedMessagesContent
        if let noteID = note.id {
            firebase.updateNoteContent(noteID: noteID, newContent: newContent)
        }
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
    }
}

struct MessageBubble: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let isMarkdown: Bool
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
    }
}

struct Message: Codable {
    let role: String
    let content: [MessageContent]
}

struct MessageContent: Codable {
    let type: String
    let text: String?
    let imageURL: ImageURL?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }
}

struct ImageURL: Codable {
    let url: String
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: ResponseMessage
}

struct ResponseMessage: Codable {
    let content: String
}
