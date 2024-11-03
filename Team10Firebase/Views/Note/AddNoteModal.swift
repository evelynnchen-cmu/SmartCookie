//
//import SwiftUI
//import FirebaseFirestore
//
//struct AddNoteModal: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var noteTitle: String = ""
//    @State private var noteContent: String = ""
//    @State private var showError = false
//    @State private var errorMessage: String = ""
//    
//    // Callback to refresh the notes view after note creation
//    var onNoteCreated: () -> Void
//    
//    @ObservedObject var firebase: Firebase
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Note Information")) {
//                    TextField("Note Title", text: $noteTitle)
//                    TextEditor(text: $noteContent)
//                        .frame(height: 150)
//                        .overlay(RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
//                        .padding(.top, 4)
//                }
//                
//                Button(action: {
//                    Task {
//                        do {
//                            try await firebase.createNote(noteTitle: noteTitle, noteContent: noteContent, courseID: "exampleCourseID")
//                            onNoteCreated()
//                            dismiss()
//                        } catch {
//                            errorMessage = error.localizedDescription
//                            showError = true
//                        }
//                    }
//                }) {
//                    Text("Create Note")
//                }
//                .disabled(noteTitle.isEmpty || noteContent.isEmpty)
//            }
//            .navigationTitle("New Note")
//            .navigationBarItems(trailing: Button("Cancel") {
//                dismiss()
//            })
//            .alert("Error", isPresented: $showError) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text(errorMessage)
//            }
//        }
//    }
//}


import SwiftUI
import FirebaseFirestore

struct AddNoteModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var noteTitle: String = ""
    @State private var noteContent: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    
    var onNoteCreated: () -> Void
    
    @ObservedObject var firebase: Firebase
    var course: Course 

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Information")) {
                    TextField("Note Title", text: $noteTitle)
                    TextEditor(text: $noteContent)
                        .frame(height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .padding(.top, 4)
                }
                
                Button(action: {
                    Task {
                        do {
                            try await firebase.createNote(
                                noteTitle: noteTitle,
                                noteContent: noteContent,
                                course: course
                            )
                            onNoteCreated()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }) {
                    Text("Create Note")
                }
                .disabled(noteTitle.isEmpty || noteContent.isEmpty)
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
}

