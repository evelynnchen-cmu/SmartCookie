import SwiftUI

struct FolderView: View {
    var folder: Folder
    @ObservedObject var firebase: Firebase
    @State private var isAddingNote = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    folderDetailsSection
                    notesSection
                }
                .padding(.leading)
            }
            .navigationTitle(folder.folderName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Note") {
                        isAddingNote = true
                    }
                }
            }
            .sheet(isPresented: $isAddingNote) {
                AddNoteModal(
                    onNoteCreated: {
                        Task {
                            do {
                                try await firebase.getNotes(for: folder)
                            } catch {
                                print("Error fetching notes: \(error.localizedDescription)")
                            }
                        }
                    },
                    firebase: firebase,
                    folder: folder
                )
            }
            .onAppear {
                Task {
                    do {
                        try await firebase.getNotes(for: folder)
                    } catch {
                        print("Error fetching notes on appear: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // Move these computed properties outside of `body`
    private var folderDetailsSection: some View {
        VStack(alignment: .leading) {
            Text("Folder ID: \(folder.id ?? "N/A")")
                .font(.body)
            Text("Course ID: \(folder.courseID)")
                .font(.body)
            Text("Folder Name: \(folder.folderName)")
                .font(.body)
            Text("File Location: \(folder.fileLocation)")
                .font(.body)
        }
    }

    private var notesSection: some View {
        let folderNotes: [Note] = firebase.notes.filter { note in
            folder.notes.contains(note.id ?? "")
        }

        return VStack(alignment: .leading) {
            ForEach(folderNotes, id: \.id) { note in
                NavigationLink(destination: NoteView(note: note)) {
                    Text(note.title)
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.vertical, 2)
                }
            }
        }
    }
}
