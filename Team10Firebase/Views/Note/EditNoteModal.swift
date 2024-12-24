//
//  EditNoteModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/2/24.
//

import SwiftUI
import FirebaseFirestore

struct EditNoteModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newTitle: String
    @State private var newContent: String
    let note: Note
    @ObservedObject var firebase: Firebase
    var onNoteUpdated: () -> Void
    
    init(note: Note, firebase: Firebase, onNoteUpdated: @escaping () -> Void) {
        self.note = note
        self.firebase = firebase
        self.onNoteUpdated = onNoteUpdated
        _newTitle = State(initialValue: note.title)
        _newContent = State(initialValue: note.content)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Information")) {
                    TextField("Title", text: $newTitle)
                    TextEditor(text: $newContent)
                        .frame(height: 200)
                }
                
                Button("Update Note") {
                    guard let noteID = note.id else { return }

                    firebase.updateNoteContentCompletion(note: note, newContent: newContent) { updatedNote in
                        if let updatedNote = updatedNote {
                          
                            firebase.updateNoteLastUpdated(noteID: noteID)
                            firebase.updateNoteTitle(note: updatedNote, newTitle: newTitle) { _ in
                                onNoteUpdated()
                                dismiss()
                            }
                        }
                    }
                }
                .disabled(newTitle.isEmpty || (newTitle == note.title && newContent == note.content))
            }
            .navigationTitle("Edit Note")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
