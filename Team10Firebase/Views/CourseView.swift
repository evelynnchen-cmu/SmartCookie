


import SwiftUI
import Combine

enum ActiveAlert: Identifiable {
    case deleteFolder
    case deleteNote

    var id: Int {
        switch self {
        case .deleteFolder: return 1
        case .deleteNote: return 2
        }
    }
}


class EditStates: ObservableObject {
    @Published var courseToEdit: Course?
    @Published var folderToEdit: Folder?
    @Published var noteToEdit: Note?
    @Published var showEditCourseModal = false
    @Published var showEditFolderModal = false
    @Published var showEditNoteModal = false
}





struct CourseView: View {
    @StateObject private var viewModel: CourseViewModel
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var folderToDelete: Folder?
    @State private var noteToDelete: Note?
    @State private var activeAlert: ActiveAlert?
    @StateObject private var editStates = EditStates()
    
    
    init(course: Course, firebase: Firebase) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(firebase: firebase, course: course))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                recentNoteSummarySection
                directNotesSection
                foldersSection
            }
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $isAddingFolder) {
            FolderModal(
                onFolderCreated: {
                    viewModel.fetchData()
                },
                firebase: viewModel.firebase,
                course: viewModel.course
            )
        }
        .sheet(isPresented: $isAddingNote) {
            AddNoteModal(
                onNoteCreated: {
                    viewModel.fetchData()
                },
                firebase: viewModel.firebase,
                course: viewModel.course,
                folder: nil
            )
        }
        .sheet(isPresented: $editStates.showEditFolderModal) {
            if let folder = editStates.folderToEdit {
                EditFolderModal(
                    folder: folder,
                    firebase: viewModel.firebase,
                    onFolderUpdated: {
                        viewModel.fetchData()
                        editStates.showEditFolderModal = false
                    }
                )
            }
        }
        .sheet(isPresented: $editStates.showEditNoteModal) {
            if let note = editStates.noteToEdit {
                EditNoteModal(
                    note: note,
                    firebase: viewModel.firebase,
                    onNoteUpdated: {
                        viewModel.fetchData()
                        editStates.showEditNoteModal = false
                    }
                )
            }
        }
      
        .onAppear {
            viewModel.fetchData()
        }
        .navigationTitle(viewModel.course.courseName)
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
                            viewModel.deleteFolder(folder)
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
                            viewModel.deleteNote(note)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var recentNoteSummarySection: some View {
        if let recentNote = viewModel.getMostRecentNote() {
            Text("Most Recent Note's Summary: \(recentNote.summary)")
                .font(.subheadline)
                .foregroundColor(.gray)
        } else {
            Text("No note available")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
  
  private let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      return formatter
  }()
    
  
//  private var directNotesSection: some View {
//      VStack(alignment: .leading) {
//          Text("Notes in Course")
//              .font(.headline)
//          
//          ForEach(viewModel.notes, id: \.id) { note in
//              HStack {
//                  NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note, course: viewModel.course)) {
//                      VStack(alignment: .leading) {
//                          Text(note.title)
//                              .font(.body)
//                              .foregroundColor(.blue)
//                          Text(note.summary)
//                              .font(.caption)
//                              .foregroundColor(.gray)
//                          Text("Created at: \(note.createdAt, formatter: dateFormatter)")
//                              .font(.caption2)
//                              .foregroundColor(.secondary)
//                      }
//                      .padding(.vertical, 5)
//                  }
//                  
//                  Spacer()
//                  
//                  Button(action: {
//                      editStates.noteToEdit = note
//                      editStates.showEditNoteModal = true
//                  }) {
//                      Image(systemName: "pencil.circle.fill")
//                          .font(.title3)
//                          .foregroundColor(.blue)
//                  }
//              }
//              .contextMenu {
//                  Button(role: .destructive) {
//                      noteToDelete = note
//                      activeAlert = .deleteNote
//                  } label: {
//                      Label("Delete Note", systemImage: "trash")
//                  }
//              }
//          }
//      }
//      .padding(.top, 10)
//  }
  
  private var directNotesSection: some View {
      VStack(alignment: .leading) {
          Text("Notes in Course")
              .font(.headline)
          
          ForEach(viewModel.notes, id: \.id) { note in
              HStack {
                  NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note, course: viewModel.course)) {
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
                  
                  Button(action: {
                      editStates.noteToEdit = note
                      editStates.showEditNoteModal = true
                  }) {
                      Image(systemName: "pencil.circle")
                          .font(.caption) // Smaller size
                          .foregroundColor(.blue)
                  }
                  .padding(.leading, 8) // Add slight spacing
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


//  private var foldersSection: some View {
//      VStack(alignment: .leading) {
//          Text("Folders")
//              .font(.headline)
//          
//          ForEach(viewModel.folders, id: \.id) { folder in
//              HStack {
//                  NavigationLink(
//                      destination: FolderView(
//                          firebase: viewModel.firebase,
//                          course: viewModel.course,
//                          folderViewModel: FolderViewModel(firebase: viewModel.firebase, folder: folder, course: viewModel.course)
//                      )
//                  ) {
//                      Text(folder.folderName)
//                          .font(.body)
//                          .foregroundColor(.blue)
//                          .padding()
//                          .background(Color.gray.opacity(0.2))
//                          .cornerRadius(8)
//                          .padding(.vertical, 2)
//                  }
//                  
//                  Spacer()
//                  
//                  Button(action: {
//                      editStates.folderToEdit = folder
//                      editStates.showEditFolderModal = true
//                  }) {
//                      Image(systemName: "pencil.circle.fill")
//                          .font(.title3)
//                          .foregroundColor(.blue)
//                  }
//              }
//              .contextMenu {
//                  Button(role: .destructive) {
//                      folderToDelete = folder
//                      activeAlert = .deleteFolder
//                  } label: {
//                      Label("Delete Folder", systemImage: "trash")
//                  }
//              }
//          }
//      }
//  }
  
  private var foldersSection: some View {
      VStack(alignment: .leading) {
          Text("Folders")
              .font(.headline)
          
          ForEach(viewModel.folders, id: \.id) { folder in
              HStack {
                  NavigationLink(
                      destination: FolderView(
                          firebase: viewModel.firebase,
                          course: viewModel.course,
                          folderViewModel: FolderViewModel(firebase: viewModel.firebase, folder: folder, course: viewModel.course)
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
                  
                  Button(action: {
                      editStates.folderToEdit = folder
                      editStates.showEditFolderModal = true
                  }) {
                      Image(systemName: "pencil.circle")
                          .font(.caption) // Smaller size
                          .foregroundColor(.blue)
                  }
                  .padding(.leading, 8) // Add slight spacing
              }
              .contextMenu {
                  Button(role: .destructive) {
                      folderToDelete = folder
                      activeAlert = .deleteFolder
                  } label: {
                      Label("Delete Folder", systemImage: "trash")
                  }
              }
          }
      }
  }

}
