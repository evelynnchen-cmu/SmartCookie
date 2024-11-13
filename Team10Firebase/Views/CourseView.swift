
import SwiftUI
import Combine

struct CourseView: View {
    @StateObject private var firebase = Firebase()
    var course: Course
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var courseFolders: [Folder] = []
    @State private var folderToDelete: Folder?
    @State private var showDeleteFolderAlert = false
    @State private var directCourseNotes: [Note] = []
    @State private var noteToDelete: Note?
  

  enum ActiveAlert: Identifiable {
    case deleteFolder, deleteNote
    
    var id: Int {
      switch self {
      case .deleteFolder: return 1
      case .deleteNote: return 2
      }
    }
  }
  
  @State private var activeAlert: ActiveAlert?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                courseDetailsSection
                recentNoteSummarySection
                directNotesSection
                foldersSection
            }
            .padding(.leading)
        }
        .sheet(isPresented: $isAddingFolder) {
            FolderModal(
                onFolderCreated: {
                    fetchFoldersForCourse()
                },
                firebase: firebase,
                course: course
            )
        }
        .sheet(isPresented: $isAddingNote) {
            AddNoteModal(
                onNoteCreated: {
                    fetchDirectNotesForCourse()
                },
                firebase: firebase,
                course: course,
                folder: nil
            )
        }
        .onAppear {
            firebase.getNotes()
            fetchFoldersForCourse()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  fetchDirectNotesForCourse()
            }
        }
        .onReceive(firebase.$notes) { _ in
            fetchDirectNotesForCourse()
        }
        .navigationTitle(course.courseName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Add Note") {
                        isAddingNote = true
                    }
                    Button("Add Folder") {
                        isAddingFolder = true
                    }
                }
            }
        }
        .alert(item: $activeAlert) { alert in
          switch alert {
          case .deleteFolder:
            return Alert(
              title: Text("Delete Folder"),
              message: Text("Are you sure you want to delete this folder and all its notes?"),
              primaryButton: .destructive(Text("Delete")) {
                if let folder = folderToDelete {
                  firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
                    if let error = error {
                      print("Error deleting folder: \(error.localizedDescription)")
                    } else {
                      courseFolders.removeAll { $0.id == folder.id }
                      fetchFoldersForCourse()
                    }
                    
                  }
                }
              },
              secondaryButton: .cancel()
            )
          case .deleteNote:
            return Alert(
              title: Text("Delete Note"),
              message: Text("Are you sure you want to delete this note?"),
              primaryButton: .destructive(Text("Delete")) {
                if let note = noteToDelete {
                  deleteDirectNote(note)
                }
              },
              secondaryButton: .cancel()
            )
          }
          
        }
    }

    private var courseDetailsSection: some View {
        VStack(alignment: .leading) {
            Text("Course ID: \(course.id ?? "N/A")")
                .font(.body)
            Text("User ID: \(course.userID)")
                .font(.body)
            Text(course.courseName)
                .font(.body)
            Text("Folders: \(course.folders.joined(separator: ", "))")
                .font(.body)
            Text("File Location: \(course.fileLocation)")
                .font(.body)
        }
    }

    private var recentNoteSummarySection: some View {
        if let recentNote = getMostRecentNoteForCourse(courseID: course.id!) {
            Text("Most Recent Note's Summary: \(recentNote.summary)")
                .font(.subheadline)
                .foregroundColor(.gray)
        } else {
            Text("No note available")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var directNotesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes in Course")
                .font(.headline)
            
            ForEach(directCourseNotes, id: \.id) { note in
                NavigationLink(destination: NoteView(firebase: firebase, note: note)) {
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
                        activeAlert = .deleteNote
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.top, 10)
    }

    private var foldersSection: some View {
        VStack(alignment: .leading) {
            Text("Folders")
                .font(.headline)

            ForEach(courseFolders, id: \.id) { folder in
                NavigationLink(
                    destination: FolderView(
                        firebase: firebase,
//                        folder: folder,
                        course: course,
                        folderViewModel: FolderViewModel(firebase: firebase, folder: folder, course: course)
                        
                    )
                ) {
                    Text(folder.folderName)
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.vertical, 2)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        folderToDelete = folder
                        print("Vicky hits delete here")
//                        showDeleteFolderAlert = true
                        activeAlert = .deleteFolder
                        print("Delete Folder button tapped")
                    } label: {
                        Label("Delete Folder", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    private func fetchFoldersForCourse() {
        firebase.getNotes()
        firebase.getFolders { allFolders in
            self.courseFolders = allFolders.filter { folder in
                course.folders.contains(folder.id ?? "")
            }
        }
    }

  private func fetchDirectNotesForCourse() {
      directCourseNotes = firebase.notes.filter { note in
          let containsNote = course.notes.contains(note.id ?? "")
          return containsNote
      }
      print("Filtered directCourseNotes count: \(directCourseNotes.count)")
  }

    private func deleteDirectNote(_ note: Note) {
        guard let noteID = note.id else { return }
        firebase.deleteNote(note: note, folderID: nil) { error in
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                fetchDirectNotesForCourse()
            }
        }
    }

    private func getMostRecentNoteForCourse(courseID: String) -> Note? {
        let filteredNotes = directCourseNotes
        let sortedNotes = filteredNotes.sorted { $0.createdAt > $1.createdAt }
        return sortedNotes.first
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

