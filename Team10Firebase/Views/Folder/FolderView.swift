//
//  FolderView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/31/24.
//

import SwiftUI

class FolderEditStates: ObservableObject {
    @Published var noteToEdit: Note?
    @Published var showEditNoteModal = false
    @Published var showPlusActions = false
}

struct FolderView: View {
    @ObservedObject var firebase: Firebase
    var course: Course
    @StateObject var folderViewModel: FolderViewModel
    @StateObject private var editStates = FolderEditStates()
    @State private var showAddNoteModal = false
    @State private var noteToDelete: Note?
    @State private var showDeleteNoteAlert = false
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(folderViewModel.folder.folderName)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), alignment: .top),
                    GridItem(.flexible(), alignment: .top),
                    GridItem(.flexible(), alignment: .top)
                ], spacing: 10) {
                    ForEach(folderViewModel.notes, id: \.id) { note in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: NoteView(firebase: firebase, note: note, course: course)) {
                                VStack {
                                  Image(systemName: "text.document.fill")
                                      .resizable()
                                      .aspectRatio(contentMode: .fit)
                                      .frame(width: 70, height: 70)
                                      .foregroundColor(tan)
                                    Text(note.title)
                                        .font(.body)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                editStates.noteToEdit = note
                                editStates.showEditNoteModal = true
                            }) {
                                Label("Edit Note", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                noteToDelete = note
                                showDeleteNoteAlert = true
                            } label: {
                                Label("Delete Note", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editStates.showPlusActions = true
                }) {
                    Image(systemName: "document.badge.plus")
                        .foregroundColor(darkBrown)
                        .imageScale(.large)
                }
            }
        }
        .confirmationDialog("Create", isPresented: $editStates.showPlusActions, titleVisibility: .hidden) {
            Button("New Note") {
                showAddNoteModal = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showAddNoteModal) {
            AddNoteModal(
                onNoteCreated: {
                    folderViewModel.fetchNotes()
                },
                firebase: firebase,
                course: course,
                folder: folderViewModel.folder,
                navigationPath: $navigationPath
            )
        }
        .sheet(isPresented: $editStates.showEditNoteModal) {
            if let note = editStates.noteToEdit {
                EditNoteModal(
                    note: note,
                    firebase: firebase,
                    onNoteUpdated: {
                        folderViewModel.fetchNotes()
                        editStates.showEditNoteModal = false
                    }
                )
            }
        }
        .onAppear {
            folderViewModel.fetchNotes()
        }
        .alert(isPresented: $showDeleteNoteAlert) {
            Alert(
                title: Text("Delete Note"),
                message: Text("Are you sure you want to delete this note?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let note = noteToDelete {
                        firebase.deleteNote(note: note, folderID: folderViewModel.folder.id ?? "") { error in
                            if let error = error {
                                print("Error deleting note: \(error.localizedDescription)")
                            } else {
                                folderViewModel.fetchNotes()
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
