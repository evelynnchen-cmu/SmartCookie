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
    @State private var suggestedMessages: [String] = []
    
    @ObservedObject private var firebase = Firebase()
    @Binding var isChatViewPresented: Bool?

    @FocusState private var isTextFieldFocused: Bool
  
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
        } else {
            self._isChatViewPresented = .constant(nil)
        }
        if let course = selectedCourse {
            self.selectedCourse = course
            self.selectedScope = course.id ?? "General"
        } else {
            self.selectedScope = "General"
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ChatHeaderView(
                    selectedScope: $selectedScope,
                    isMessageSelectionViewPresented: $isMessageSelectionViewPresented,
                    isChatViewPresented: $isChatViewPresented,
                    firebase: firebase
                )

                ChatMessagesView(
                    messages: $messages,
                    selectedMessages: $selectedMessages,
                    isMessageSelectionViewPresented: $isMessageSelectionViewPresented,
                    isLoading: $isLoading,
                    notesOnlyChatScope: notesOnlyChatScope
                )

                SuggestedMessagesView(
                    userInput: $userInput,
                    suggestedMessages: $suggestedMessages
                )

                ChatInputView(
                    userInput: $userInput,
                    isLoading: $isLoading,
                    sendMessage: sendMessage
                )
                .focused($isTextFieldFocused)
                .onTapGesture {
                    isTextFieldFocused = true
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 50 {
                            isTextFieldFocused = false // Dismiss keyboard on swipe down
                        }
                    }
            )
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
                fetchSuggestions()
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
            .onDisappear {
                isTextFieldFocused = false
            }
            .onChange(of: messages) {
                fetchSuggestions()
            }
            .onChange(of: selectedScope) { oldScope, newScope in
                if newScope != "General" {
                    fetchNotes(for: newScope)
                } else {
                    courseNotes = []
                }
                clearChat()
                fetchSuggestions()
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
                    let cleanResponse = stripMarkdown(choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                    completion(cleanResponse)
                } else {
                    completion("Unexpected response format.")
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                completion("Failed to parse API response.")
            }
        }.resume()
    }

    // Helper function to strip Markdown formatting
    func stripMarkdown(_ text: String) -> String {
        // Remove bold, italic, and other Markdown formatting
        let patterns = [
            "\\*\\*(.*?)\\*\\*", // Bold
            "\\*(.*?)\\*",       // Italics
            "_([^_]+)_",         // Underscore-based Italics
            "`([^`]+)`",         // Inline code
            "\\[([^\\]]+)\\]\\([^\\)]+\\)" // Links
        ]
        var cleanText = text
        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            cleanText = regex?.stringByReplacingMatches(in: cleanText, options: [], range: NSRange(location: 0, length: cleanText.utf16.count), withTemplate: "$1") ?? cleanText
        }
        return cleanText
    }

    // Fetches notes for a specific course and updates courseNotes.
    // - Parameter courseID: The ID of the course for which to fetch notes.
    func fetchNotes(for courseID: String) {
        courseNotes = firebase.notes.filter { $0.courseID == courseID }
    }

    func clearChat() {
        messages.removeAll()
        messagesHistory = [["role": "system", "content": systemPrompt]]

        let welcomeMessage: String
        if selectedScope == "General" {
            welcomeMessage = "Hello, you're in the general chat, where you can ask questions about any topic. If you'd like me to reference a specific course's notes, please select a course from the dropdown menu above. Don't forget to save any useful responses to your notes before exiting!"
        } else {
            let courseName = firebase.courses.first(where: { $0.id == selectedScope })?.courseName ?? "selected course"
            let sampleNotes = courseNotes.prefix(3).map { $0.title }.joined(separator: ", ")
            welcomeMessage = "Hello, you're in the \(courseName) chat. I can see your notes, including \(sampleNotes). Ask me anything!"
        }

        messages.append(MessageBubble(content: welcomeMessage, isUser: false, isMarkdown: true))
        messagesHistory.append(["role": "assistant", "content": welcomeMessage])
    }
    
    // Calls OpenAI API to get suggested short sentence/question starters for the user
    func fetchSuggestions() {
        var contextMessages = messagesHistory

        if let course = selectedCourse {
            let coursePrompt = """
            Course: \(course.courseName ?? "Unknown")
            Context: This is a study assistant app. The user is chatting about this course and may want to ask questions, explore concepts, or seek clarification related to the course material.
            Objective: Provide concise, actionable, and contextually relevant suggestions for short sentence or question starters. These starters should:
            - Be 2-6 words in length
            - Focus on exploring, applying, comparing, or solving course concepts
            - Encourage the user to elaborate or ask specific questions
            Examples:
            - "Explain how to_"
            - "Describe the differences_"
            - "What happens if_"
            - "How can I use_"
            - "Help me solve_"
            Output format: Provide at least 5 such suggestions as plain text, separated by commas, with no quotes, bullet points, or special formatting.
            """
            contextMessages.append(["role": "system", "content": coursePrompt])
        } else {
            contextMessages.append([
                "role": "system",
                "content": """
                Context: This is a general study assistant chat. The user may want to ask about various topics or seek help on academic problems.
                Objective: Provide concise, actionable, and contextually relevant suggestions for short sentence or question starters. These starters should:
                - Be 2-6 words in length
                - Focus on exploring, applying, comparing, or solving general concepts
                - Encourage the user to elaborate or ask specific questions
                Examples:
                - "Explain how to_"
                - "Describe the differences_"
                - "What happens if_"
                - "How can I use_"
                - "Help me solve_"
                Output format: Provide at least 5 such suggestions as plain text, separated by commas, with no quotes, bullet points, or special formatting.
                """
            ])
        }

        callChatGPTAPI(with: contextMessages) { response in
            DispatchQueue.main.async {
                print("Suggestions API Response: \(response)")
                let suggestions = response.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                if suggestions.isEmpty {
                    // Fallback to backup suggestions if parsing fails
                    self.suggestedMessages = [
                        "Explain how to_",
                        "Describe the differences_",
                        "What happens if_",
                        "How can I use_",
                        "Help me solve_"
                    ]
                } else {
                    self.suggestedMessages = suggestions
                }
                print("Updated Suggested Messages: \(self.suggestedMessages)")
            }
        }
    }
}

struct MessageBubble: Identifiable, Equatable {
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

struct ChatInputView: View {
    @Binding var userInput: String
    @Binding var isLoading: Bool
    var sendMessage: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $userInput)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(userInput.isEmpty ? lightBlue : mediumBlue)
            }
            .disabled(isLoading || userInput.isEmpty)
        }
        .padding()
    }
}
