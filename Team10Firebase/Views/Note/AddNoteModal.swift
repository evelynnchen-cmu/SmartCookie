//
//  AddNoteModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/2/24.
//

import SwiftUI
import FirebaseFirestore

struct AddNoteModal: View {
    var openAI: OpenAI = OpenAI()
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
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Note")) {
                    TextField("Name", text: $title)
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
            var summary = "Add note content by editing or uploading images/PDFs to generate a summary."
            if !content.isEmpty {
                summary = try await openAI.summarizeContent(content: content)
            }
            
            // Determine note location based on whether folder is provided
            firebase.createNote(
                title: title,
                summary: summary,
                content: content,
                images: images,
                course: course,
                folder: folder // Adds to folder if specified, else directly to course
            ) { (newNote, error) in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    if let newNote = newNote {
                        onNoteCreated()
                        navigationPath.append(newNote)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
