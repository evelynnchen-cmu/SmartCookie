import SwiftUI

struct PDFParserView: View {
    var pdfText: String
    var firebase: Firebase
    var openAI: OpenAI = OpenAI()
    @Binding var isPresented: Bool
    @State private var alertMessage = ""
    @State private var showAlert = false
    var course: Course?
    var title: String
    @Binding var note: Note?

    var body: some View {
        VStack {
            Text("Parsed PDF Content")
                .font(.title)
                .bold()
            
            ScrollView {
                Text(pdfText.isEmpty ? "No content found" : pdfText)
                    .onAppear {
                        print("PDF text in PDFParserView is: \(pdfText)")
                    }
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                handleSave()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleSave() {
        guard let course = course else {
            alertMessage = "Failed to get course"
            showAlert = true
            return
        }

        // Ensure the note exists
        guard let note = note else {
            alertMessage = "Failed to get note"
            showAlert = true
            return
        }

        // Append PDF text to the existing content
        let updatedContent = (note.content + "\n\n" + pdfText).trimmingCharacters(in: .whitespacesAndNewlines)

        // Update the note in Firebase
        Task {
            firebase.updateNoteContentCompletion(note: note, newContent: updatedContent) { updatedNote in
                if let updatedNote = updatedNote {
                    // Update local state
                    self.note = updatedNote
                    isPresented = false
                } else {
                    alertMessage = "Failed to update note"
                    showAlert = true
                }
            }
        }
        Task {
          var updatedSummary = "No summary"
          if let updatedNote = self.note {
            var updatedSummary = note.summary
            do {
              updatedSummary = try await openAI.summarizeContent(content: updatedContent)
              print("new summary done")
            } catch {
              alertMessage = "Failed to summarize content"
              showAlert = true
            }
            firebase.updateNoteSummary(note: updatedNote, newSummary: updatedSummary) { updatedNote in
              if let updatedNote = updatedNote {
                self.note = updatedNote
                showAlert = false
              } else {
                print("Failed to update summary")
                alertMessage = "Failed to update summary"
                showAlert = true
              }
            }
          }
        }
    }
}
