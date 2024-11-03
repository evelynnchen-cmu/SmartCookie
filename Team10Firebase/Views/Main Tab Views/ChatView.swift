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
    @State private var messagesHistory: [[String: String]] = [
        ["role": "system", "content": "You are an expert study assistant. You will only converse about topics related to the courses. Do not ask or answer any questions about personal matters or unrelated topics. You will do your best to provide accurate and helpful information to the students. You will ask clarifying questions if need be. You will be concise in your answers and know that your entire message could be saved to notes for later, so don't add any extra fluff. This is because you care very much about the user's learning and productivity, and your entire objective is to teach the user and assist them with their problems."],
    ]

    let courseScope: String

    let openAIKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OpenAIKey"] as? String else {
            fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
        }
        return key
    }()

    var body: some View {
//      Note: VStack needed or else a duplicate tab in AppView is created
      VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages) { message in
                        Text(message.content)
                            .padding()
                            .background(message.isUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                    }
                }
                .padding()
            }

            HStack {
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
    }

    func sendMessage() {
        let userMessage = userInput
        messages.append(MessageBubble(content: userMessage, isUser: true))
        userInput = ""
        isLoading = true

        messagesHistory.append(["role": "user", "content": userMessage])

        callChatGPTAPI(with: messagesHistory) { response in
            DispatchQueue.main.async {
                self.messages.append(MessageBubble(content: response, isUser: false))
                self.messagesHistory.append(["role": "assistant", "content": response])
                self.isLoading = false
            }
        }
    }

    func callChatGPTAPI(with messagesHistory: [[String: String]], completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let messages = messagesHistory.map { Message(role: $0["role"]!, content: [MessageContent(type: "text", text: $0["content"], imageURL: nil)]) }

        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: messages,
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
}

struct MessageBubble: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
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
