


import SwiftUI

struct FolderView: View {
    @ObservedObject var firebase: Firebase
//    var folder: Folder
    var course: Course

    @StateObject var folderViewModel: FolderViewModel
    
    @State private var showAddNoteModal = false

    @State private var noteToDelete: Note?
    @State private var showDeleteNoteAlert = false
    
    var body: some View {
      VStack{
        ScrollView {
          VStack(alignment: .leading) {
            
            
            Text("Notes:")
              .font(.headline)
            
            ForEach(folderViewModel.notes, id: \.id) { note in
              NavigationLink(destination: NoteView(firebase: firebase, note: note, course: course)) {
                VStack(alignment: .leading) {
                  Text(note.title)
                    .font(.body)
                    .foregroundColor(.blue)
                  Text(note.summary)
                    .font(.caption)
                    .foregroundColor(.gray)
                  Text("Created at: \(note.createdAt, formatter: dateFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
              }
              .contextMenu {
                Button(role: .destructive) {
                  noteToDelete = note
                  showDeleteNoteAlert = true
                } label: {
                  Label("Delete Note", systemImage: "trash")
                }
              }
            }
            
            Spacer()
          }
        }
        Button(action: {
            showAddNoteModal = true
        }) {
            Text("Create Note")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
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
      .padding()
      .navigationTitle("Folder Details")
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
