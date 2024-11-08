
import SwiftUI
import FirebaseFirestore

struct AddNoteModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
//    @State private var images: [URL] = []
  @State private var images: [String] = []
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    var onNoteCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    var folder: Folder
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Information")) {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content)
                    // You could add additional UI for images if needed
                }
                
                Button(action: {
                    Task {
                        await createNote()
                    }
                }) {
                    Text("Create Note")
                }
                .disabled(title.isEmpty || content.isEmpty)
            }
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createNote() async {
        do {
            let summary = try await summarizeContent(content: content)
            firebase.createNote(
                title: title,
                summary: summary,
                content: content,
                images: images,
                folder: folder,
                course: course
            ) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    onNoteCreated()
                    dismiss()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func summarizeContent(content: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let openAIKey: String = {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: filePath),
                  let key = plist["OpenAIKey"] as? String else {
                fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
            }
            return key
        }()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                Message(role: "system", content: [MessageContent(type: "text", text: "You will summarize the following content. Be concise, just touch on the main points. The summary should be readable in 15-20 seconds. Content: \(content)", imageURL: nil)])
            ],
            maxTokens: 150
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSON payload"])
        }

        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to connect to the API"])
        }

        let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        if let choice = jsonResponse.choices.first {
            return choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
        }
    }
}

