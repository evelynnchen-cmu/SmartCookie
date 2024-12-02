//
//
//
//
//import SwiftUI
//import Combine
//
//struct CourseView: View {
//    var course: Course
//    var firebase: Firebase
//    @State private var isAddingFolder = false
//    @State private var isAddingNote = false
//    @State private var courseFolders: [Folder] = []
//    @State private var directCourseNotes: [Note] = []
//    @State private var folderToDelete: Folder?
//    @State private var noteToDelete: Note?
//    @State private var activeAlert: ActiveAlert?
//
//    enum ActiveAlert: Identifiable {
//        case deleteFolder, deleteNote
//
//        var id: Int {
//            switch self {
//            case .deleteFolder: return 1
//            case .deleteNote: return 2
//            }
//        }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                recentNoteSummarySection
//                directNotesSection
//                foldersSection
//            }
//            .padding(.leading, 20)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .sheet(isPresented: $isAddingFolder) {
//            FolderModal(
//                onFolderCreated: {
//                    fetchFoldersForCourse()
//                },
//                firebase: firebase,
//                course: course
//            )
//        }
//        .sheet(isPresented: $isAddingNote) {
//            AddNoteModal(
//                onNoteCreated: {
//                    fetchDirectNotesForCourse()
//                },
//                firebase: firebase,
//                course: course,
//                folder: nil
//            )
//        }
//        .onAppear {
//            fetchFoldersForCourse()
//            fetchDirectNotesForCourse()
//        }
//        .navigationTitle(course.courseName)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                HStack {
//                    Button("Add Note") {
//                        isAddingNote = true
//                    }
//                    Button("Add Folder") {
//                        isAddingFolder = true
//                    }
//                }
//            }
//        }
//        .alert(item: $activeAlert) { alert in
//            switch alert {
//            case .deleteFolder:
//                return Alert(
//                    title: Text("Delete Folder"),
//                    message: Text("Are you sure you want to delete this folder and all its notes?"),
//                    primaryButton: .destructive(Text("Delete")) {
//                        if let folder = folderToDelete {
//                            deleteFolder(folder)
//                        }
//                    },
//                    secondaryButton: .cancel()
//                )
//            case .deleteNote:
//                return Alert(
//                    title: Text("Delete Note"),
//                    message: Text("Are you sure you want to delete this note?"),
//                    primaryButton: .destructive(Text("Delete")) {
//                        if let note = noteToDelete {
//                            deleteDirectNote(note)
//                        }
//                    },
//                    secondaryButton: .cancel()
//                )
//            }
//        }
//    }
//
//    private var recentNoteSummarySection: some View {
//        if let recentNote = getMostRecentNoteForCourse() {
//            Text("Most Recent Note's Summary: \(recentNote.summary)")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        } else {
//            Text("No note available")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        }
//    }
//
//    private var directNotesSection: some View {
//        VStack(alignment: .leading) {
//            Text("Notes in Course")
//                .font(.headline)
//
//            ForEach(directCourseNotes, id: \.id) { note in
//                NavigationLink(destination: NoteView(firebase: firebase, note: note, course: course)) {
//                    VStack(alignment: .leading) {
//                        Text(note.title)
//                            .font(.body)
//                            .foregroundColor(.blue)
//                        Text(note.summary)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        Text("Created at: \(note.createdAt, formatter: dateFormatter)")
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(.vertical, 5)
//                }
//                .contextMenu {
//                    Button(role: .destructive) {
//                        noteToDelete = note
//                        activeAlert = .deleteNote
//                    } label: {
//                        Label("Delete Note", systemImage: "trash")
//                    }
//                }
//            }
//        }
//        .padding(.top, 10)
//    }
//
//    private var foldersSection: some View {
//        VStack(alignment: .leading) {
//            Text("Folders")
//                .font(.headline)
//
//            ForEach(courseFolders, id: \.id) { folder in
//                NavigationLink(
//                    destination: FolderView(
//                        firebase: firebase,
//                        course: course,
//                        folderViewModel: FolderViewModel(firebase: firebase, folder: folder, course: course)
//                    )
//                ) {
//                    Text(folder.folderName)
//                        .font(.body)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                        .padding(.vertical, 2)
//                }
//                .contextMenu {
//                    Button(role: .destructive) {
//                        folderToDelete = folder
//                        activeAlert = .deleteFolder
//                    } label: {
//                        Label("Delete Folder", systemImage: "trash")
//                    }
//                }
//            }
//        }
//    }
//
//    private func fetchFoldersForCourse() {
//        firebase.getFolders { allFolders in
//            self.courseFolders = allFolders.filter { folder in
//                course.folders.contains(folder.id ?? "")
//            }
//        }
//    }
//
//    private func fetchDirectNotesForCourse() {
//        directCourseNotes = firebase.notes.filter { note in
//            course.notes.contains(note.id ?? "")
//        }
//    }
//
//    private func deleteFolder(_ folder: Folder) {
//        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
//            if let error = error {
//                print("Error deleting folder: \(error.localizedDescription)")
//            } else {
//                fetchFoldersForCourse()
//            }
//        }
//    }
//
//    private func deleteDirectNote(_ note: Note) {
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if let error = error {
//                print("Error deleting note: \(error.localizedDescription)")
//            } else {
//                fetchDirectNotesForCourse()
//            }
//        }
//    }
//
//    private func getMostRecentNoteForCourse() -> Note? {
//        let sortedNotes = directCourseNotes.sorted { $0.createdAt > $1.createdAt }
//        return sortedNotes.first
//    }
//}
//
//private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .short
//    return formatter
//}()
//
//
//


import SwiftUI
import Combine

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
//    @State private var selectedFolder: Folder?
    @State private var selectedFolderId: String? = nil

    enum ActiveAlert: Identifiable {
        case deleteFolder, deleteNote

        var id: Int {
            switch self {
            case .deleteFolder: return 1
            case .deleteNote: return 2
            }
        }
    }

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
//                    onFolderUpdated: { updatedFolder in
//                        // Update the folder in the view model
//                        if let index = viewModel.folders.firstIndex(where: { $0.id == folder.id }) {
//                            viewModel.folders[index] = updatedFolder
//                            
//                            // Update selectedFolder if it was the one being edited
//                            if selectedFolder?.id == folder.id {
//                                selectedFolder = updatedFolder
//                            }
//                        }
//                        
//                        // Fetch updated data without triggering a full view refresh
//                        Task {
//                            await viewModel.fetchDataQuietly()
//                        }
//                        
//                        editStates.showEditFolderModal = false
//                    }
                    onFolderUpdated: { updatedFolder in
                        // Update the folder in the view model
                        if let index = viewModel.folders.firstIndex(where: { $0.id == folder.id }) {
                            viewModel.folders[index] = updatedFolder
                        }
                        
                        // Fetch updated data without triggering a full view refresh
                        Task {
                            await viewModel.fetchDataQuietly()
                        }
                        
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
                    onNoteUpdated: { updatedNote in
                        if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                            viewModel.notes[index] = updatedNote
                        }
                        Task {
                            await viewModel.fetchDataQuietly()
                        }
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
        VStack(alignment: .leading) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

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
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
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

          ForEach(viewModel.folders, id: \.id) { folder in
              HStack {
                  NavigationLink(
                      tag: folder.id ?? "",
                      selection: $selectedFolderId,
                      destination: {
                          if let folder = viewModel.folders.first(where: { $0.id == folder.id }) {
                              FolderView(
                                  firebase: viewModel.firebase,
                                  course: viewModel.course,
                                  folderViewModel: FolderViewModel(
                                      firebase: viewModel.firebase,
                                      folder: folder,
                                      course: viewModel.course
                                  )
                              )
                          }
                      }
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
                          .font(.caption)
                          .foregroundColor(.blue)
                  }
                  .padding(.leading, 8)
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

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
