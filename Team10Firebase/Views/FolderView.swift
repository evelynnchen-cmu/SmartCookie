
import SwiftUI

struct FolderView: View {
    @ObservedObject var firebase: Firebase
    var folder: Folder
    var course: Course
    
    @State private var showAddNoteModal = false
    @State private var notes: [Note] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Folder Name: \(folder.folderName)")
                .font(.title)
                .padding(.bottom, 2)
            
            Text("Course ID: \(folder.courseID)")
                .font(.body)
            
            if let userID = folder.userID {
                Text("User ID: \(userID)")
                    .font(.body)
            }
            
            Text("File Location: \(folder.fileLocation)")
                .font(.body)
            
            if let recentNoteSummary = folder.recentNoteSummary {
                Text("Recent Note Title: \(recentNoteSummary.title)")
                    .font(.body)
                Text("Summary: \(recentNoteSummary.summary)")
                    .font(.body)
            }
            
            Divider().padding(.vertical, 10)
            
            Text("Notes:")
                .font(.headline)
            
            ForEach(notes, id: \.id) { note in
                NavigationLink(destination: NoteView(note: note)) {
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
            }
            
            Spacer()
            
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
                        fetchNotes()
                    },
                    firebase: firebase,
                    course: course,
                    folder: folder
                )
            }
        }
        .padding()
        .navigationTitle("Folder Details")
        .onAppear {
            fetchNotes()
        }
    }
    

    private func fetchNotes() {
        firebase.getNotes()
        
        notes = firebase.notes.filter { $0.courseID == course.id && folder.notes.contains($0.id ?? "") }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

