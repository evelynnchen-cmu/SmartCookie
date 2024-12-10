


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


    var body: some View {
      ZStack {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Notes")
              .font(.headline)
            LazyVGrid(columns: [
                GridItem(.flexible(), alignment: .top),
                GridItem(.flexible(), alignment: .top),
                GridItem(.flexible(), alignment: .top),
                GridItem(.flexible(), alignment: .top)
            ], spacing: 10) {
                ForEach(folderViewModel.notes, id: \.id) { note in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(destination: NoteView(firebase: firebase, note: note, course: course)) {
                            VStack {
                                Image("note")
                                    .resizable()
                                    .frame(width: 70, height: 70)
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
            Spacer()
          }
        }
        
        VStack {
            Spacer()
            HStack {
              Spacer()
                Button(action: {
                    editStates.showPlusActions = true
                }) {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.bottom, 20)
            .padding(.trailing, 20)
        }
        .confirmationDialog("Create", isPresented: $editStates.showPlusActions, titleVisibility: .hidden) {
            Button("New Note") {
                showAddNoteModal = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .padding(.top, 20)
        .sheet(isPresented: $showAddNoteModal) {
            AddNoteModal(
                onNoteCreated: {
                  folderViewModel.fetchNotes()
                },
                // updateFolderNotes: {
                //   folderViewModel.updateFolderNotes()
                // },
                firebase: firebase,
                course: course,
                folder: folderViewModel.folder
            )
        }
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

      .padding()
      .navigationTitle("\(folderViewModel.folder.folderName)")
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
