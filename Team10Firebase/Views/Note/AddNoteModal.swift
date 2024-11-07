
import SwiftUI
import FirebaseFirestore

struct AddNoteModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var images: [URL] = []
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
                        createNote()
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
    
    private func createNote() {
        // Provide an empty string as a default for summary if it’s removed
        firebase.createNote(
            title: title,
            summary: "",
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
    }
}

