import SwiftUI
import FirebaseFirestore

struct AddNoteModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var images: [String] = []
    @State private var showError = false
    @State private var errorMessage: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showTextParserView = false
    
    var onNoteCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    var folder: Folder? // Optional, if provided, note is added to this folder; otherwise, directly to course

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Information")) {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content)
                }
                
                Button(action: {
                    Task {
                        await createNote()
                    }
                    self.showTextParserView = true
                    dismiss()
                }) {
                    Text("Create Note")
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
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
            
            // Determine note location based on whether folder is provided
            firebase.createNote(
                title: title,
                summary: summary,
                content: content,
                images: images,
                course: course,
                folder: folder // Adds to folder if specified, else directly to course
            ) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
//                    updateFolderNotes()
                    onNoteCreated()
//                    dismiss()
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
    
//  Testing helper
    #if DEBUG
    @Binding var testTitle: String
    @Binding var testContent: String
    #endif
}
