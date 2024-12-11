//
//  ChatView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI
import Foundation
import Combine

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
    @State private var lastValidScope: String
    @State private var isCoursesLoaded: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var lastWelcomeScope: String?
    @State private var isClearingChat = false
    @State private var localCourses: [Course] = []
    @State private var localNotes: [String: [Note]] = [:]

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
            self.lastValidScope = course.id ?? "General"
        } else {
            self.selectedScope = "General"
            self.lastValidScope = "General"
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
                print("ChatView appeared with selectedScope: \(selectedScope)")

                if selectedScope != "General" {
                    fetchNotes(for: selectedScope) { _ in
                        clearChat()
                    }
                } else {
                    courseNotes = []
                    clearChat()
                }
            }
            .onChange(of: messages) {
                fetchSuggestions()
            }
            .onChange(of: selectedScope) { oldScope, newScope in
                guard newScope != oldScope else { return } // Prevent unnecessary updates
                print("Scope changed from \(oldScope) to \(newScope)")
                
                // Clear chat and fetch notes for the new scope
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

    private func loadInitialData() {
        print("Loading initial data...")
        firebase.getCourses()

        firebase.$courses
            .receive(on: DispatchQueue.main)
            .sink { courses in
                print("Received courses update: \(courses.count) courses")
                self.isCoursesLoaded = true
            }
            .store(in: &cancellables)
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

        // Add notes context
        let notesContext = courseNotes.map { note in
            let formattedDate = DateFormatter.localizedString(from: note.createdAt, dateStyle: .long, timeStyle: .short)
            return """
            Title: \(note.title)
            Summary: \(note.summary)
            Date: \(formattedDate)
            Content: \(note.content)
            """
        }.joined(separator: "\n\n")

        // Check if notes are empty
        if notesContext.isEmpty {
            print("No notes available for context.")
        }

        // Prepare the system message
        let systemMessage = [
            "role": "system",
            "content": """
            You are a study assistant with access to the user's course notes. Here are the notes:
            \(notesContext.isEmpty ? "No notes available." : notesContext)

            Assist the user by answering their questions or summarizing these notes. If the user asks about a specific lecture or concept, provide details from the notes above.
            """
        ]

        // Combine the system message and user messages
        let combinedMessages = [systemMessage] + messagesHistory

        let requestBody = [
            "model": "gpt-4o-mini",
            "messages": combinedMessages,
            "max_tokens": 300
        ] as [String: Any]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to serialize JSON.")
            return
        }

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error.localizedDescription)")
                completion("Failed to connect to the API.")
                return
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
                print("Failed to parse JSON: \(error.localizedDescription)")
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
    func fetchNotes(for courseID: String, completion: @escaping ([Note]) -> Void) {
        print("Fetching notes for course ID: \(courseID)")

        // Try fetching from Firebase
        firebase.getNotes()

        firebase.$notes
            .receive(on: DispatchQueue.main)
            .sink { notes in
                let filteredNotes = notes.filter { $0.courseID == courseID }
                if !filteredNotes.isEmpty {
                    print("Fetched \(filteredNotes.count) notes from Firebase for course \(courseID)")
                    self.courseNotes = filteredNotes
                    completion(filteredNotes)
                } else {
                    // Fallback to local notes if Firebase fetch fails or is empty
                    print("Using local notes for course \(courseID)")
                    let localFilteredNotes = self.localNotes[courseID] ?? []
                    self.courseNotes = localFilteredNotes
                    completion(localFilteredNotes)
                }
            }
            .store(in: &cancellables)
    }

    // Clears the chat view and resets the message history.
    func clearChat() {
        // Remove all messages and reset history
        messages.removeAll()
        messagesHistory = [["role": "system", "content": systemPrompt]]

        if selectedScope == "General" {
            let generalWelcomeMessage = """
            Hello, you're in the general chat, where you can ask questions about any topic. 
            If you'd like me to reference a specific course's notes, please select a course from the dropdown menu above. 
            You can also use the clickable prompts at the bottom to start a conversation. 
            Don't forget to save any useful responses to your notes before exiting!
            """
            // Add general chat welcome message
            messages.append(MessageBubble(content: generalWelcomeMessage, isUser: false, isMarkdown: true))
            messagesHistory.append(["role": "assistant", "content": generalWelcomeMessage])
        } else {
            // Fetch course-specific notes
            fetchNotes(for: selectedScope) { notes in
                DispatchQueue.main.async {
                    // Ensure we are clearing previous welcome messages for consistency
                    self.messages.removeAll()

                    let courseName = self.firebase.courses.first(where: { $0.id == self.selectedScope })?.courseName ?? "selected course"
                    let courseWelcomeMessage: String

                    if notes.isEmpty {
                        courseWelcomeMessage = """
                        Hello, you're in the \(courseName) chat. I don't see any notes for this course yet. 
                        Feel free to ask general questions about \(courseName), or use the clickable prompts at the bottom of the screen to start a conversation.
                        """
                    } else {
                        let sampleNotes = notes.prefix(3).map { $0.title }.joined(separator: ", ")
                        courseWelcomeMessage = """
                        Hello, you're in the \(courseName) chat, and I can see your notes including \(sampleNotes). 
                        Feel free to type out any questions about the material from this course, or use the clickable prompts at the bottom to start a conversation. 
                        Don't forget to save any useful responses to your notes before exiting!
                        """
                    }

                    // Add the welcome message for the specific course
                    self.messages.append(MessageBubble(content: courseWelcomeMessage, isUser: false, isMarkdown: true))
                    self.messagesHistory.append(["role": "assistant", "content": courseWelcomeMessage])
                }
            }
        }
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
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(userInput.isEmpty ? lightBlue : mediumBlue)
            }
            .disabled(isLoading || userInput.isEmpty)
        }
        .padding()
    }
}

