//
//
//
//import SwiftUI
//import Combine
//
//
//
//struct CourseView: View {
//    @ObservedObject var firebase: Firebase
//    var course: Course
//    @StateObject private var viewModel: CourseViewModel
//    @State private var courseFolders: [Folder] = []
//    @State private var directCourseNotes: [Note] = []
//    @State private var isAddingFolder = false
//    @State private var isAddingNote = false
//    @State private var folderToDelete: Folder?
//    @State private var noteToDelete: Note?
//    @State private var activeAlert: ActiveAlert?
//  
//    enum ActiveAlert: Identifiable {
//        case deleteFolder, deleteNote
//        
//        var id: Int {
//          switch self {
//          case .deleteFolder: return 1
//          case .deleteNote: return 2
//          }
//        }
//      }
//  
//  
//  
//    init(course: Course, firebase: Firebase) {
//        self.course = course
//        self.firebase = firebase
//        _viewModel = StateObject(wrappedValue: CourseViewModel(firebase: firebase, course: course))
//    }
//  
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
//                    viewModel.fetchData()
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course
//            )
//        }
//        .sheet(isPresented: $isAddingNote) {
//            AddNoteModal(
//                onNoteCreated: {
//                    viewModel.fetchData()
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course,
//                folder: nil
//            )
//        }
//        .onAppear {
//            viewModel.fetchData()
//        }
//        .navigationTitle(viewModel.course.courseName)
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
//                            viewModel.deleteFolder(folder)
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
//                            viewModel.deleteNote(note)
//                        }
//                    },
//                    secondaryButton: .cancel()
//                )
//            }
//        }
//    }
//    
//    private var recentNoteSummarySection: some View {
//        if let recentNote = viewModel.getMostRecentNote() {
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
//  private let dateFormatter: DateFormatter = {
//      let formatter = DateFormatter()
//      formatter.dateStyle = .medium
//      formatter.timeStyle = .short
//      return formatter
//  }()
//    
////    private var directNotesSection: some View {
////        VStack(alignment: .leading) {
////            Text("Notes in Course")
////                .font(.headline)
////            
////            ForEach(viewModel.notes, id: \.id) { note in
////              NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note, course: viewModel.course)) {
////                    VStack(alignment: .leading) {
////                        Text(note.title)
////                            .font(.body)
////                            .foregroundColor(.blue)
////                        Text(note.summary)
////                            .font(.caption)
////                            .foregroundColor(.gray)
////                        Text("Created at: \(note.createdAt, formatter: dateFormatter)")
////                            .font(.caption2)
////                            .foregroundColor(.secondary)
////                    }
////                    .padding(.vertical, 5)
////                }
////                .contextMenu {
////                    Button(role: .destructive) {
////                        noteToDelete = note
////                        activeAlert = .deleteNote
////                    } label: {
////                        Label("Delete Note", systemImage: "trash")
////                    }
////                }
////            }
////        }
////        .padding(.top, 10)
////    }
////    
////    private var foldersSection: some View {
////        VStack(alignment: .leading) {
////            Text("Folders")
////                .font(.headline)
////            
////            ForEach(viewModel.folders, id: \.id) { folder in
////                NavigationLink(
////                    destination: FolderView(
////                        firebase: viewModel.firebase,
////                        course: viewModel.course,
////                        folderViewModel: FolderViewModel(firebase: viewModel.firebase, folder: folder, course: viewModel.course)
////                    )
////                ) {
////                    Text(folder.folderName)
////                        .font(.body)
////                        .foregroundColor(.blue)
////                        .padding()
////                        .background(Color.gray.opacity(0.2))
////                        .cornerRadius(8)
////                        .padding(.vertical, 2)
////                }
////                .contextMenu {
////                    Button(role: .destructive) {
////                        folderToDelete = folder
////                        activeAlert = .deleteFolder
////                    } label: {
////                        Label("Delete Folder", systemImage: "trash")
////                    }
////                }
////            }
////        }
////    }
//  
////  private var foldersSection: some View {
////      VStack(alignment: .leading) {
////          Text("Folders")
////              .font(.headline)
////
////          ForEach(courseFolders, id: \.id) { folder in
////              NavigationLink(
////                  destination: FolderView(
////                      firebase: firebase,
////                      course: course,
////                      folderViewModel: FolderViewModel(firebase: firebase, folder: folder, course: course)
////                  )
////              ) {
////                  HStack {
////                      Text(folder.folderName)
////                          .font(.body)
////                          .foregroundColor(.blue)
////                          .padding()
////                          .background(Color.gray.opacity(0.2))
////                          .cornerRadius(8)
////                          .padding(.vertical, 2)
////
////                      Spacer()
////
////                      Button(action: {
////                          folderToDelete = folder
////                          activeAlert = .deleteFolder
////                      }) {
////                          Image(systemName: "trash")
////                              .foregroundColor(.red)
////                      }
////                  }
////              }
////          }
////      }
////      .padding(.top, 10)
////  }
//  
//  private var foldersSection: some View {
//      VStack(alignment: .leading) {
//          Text("Folders")
//              .font(.headline)
//
//          ForEach(courseFolders, id: \.id) { folder in
//              NavigationLink(
//                  destination: FolderView(
//                      firebase: viewModel.firebase,
//                      course: viewModel.course,
//                      folderViewModel: FolderViewModel(firebase: viewModel.firebase, folder: folder, course: viewModel.course)
//                  )
//              ) {
//                  HStack {
//                      Text(folder.folderName)
//                          .font(.body)
//                          .foregroundColor(.blue)
//                          .padding()
//                          .background(Color.gray.opacity(0.2))
//                          .cornerRadius(8)
//                          .padding(.vertical, 2)
//
//                      Spacer()
//
//                      Button(action: {
//                          folderToDelete = folder
//                          activeAlert = .deleteFolder
//                      }) {
//                          Image(systemName: "trash")
//                              .foregroundColor(.red)
//                      }
//                  }
//              }
//          }
//      }
//      .padding(.top, 10)
//  }
//
//
//  private var directNotesSection: some View {
//      VStack(alignment: .leading) {
//          Text("Notes in Course")
//              .font(.headline)
//
//          ForEach(directCourseNotes, id: \.id) { note in
//              NavigationLink(
//                  destination: NoteView(firebase: firebase, note: note, course: course)
//              ) {
//                  HStack {
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
//
//                      Spacer()
//
//                      Button(action: {
//                          noteToDelete = note
//                          activeAlert = .deleteNote
//                      }) {
//                          Image(systemName: "trash")
//                              .foregroundColor(.red)
//                      }
//                  }
//              }
//          }
//      }
//      .padding(.top, 10)
//  }
//
//}



import SwiftUI
import Combine

struct CourseView: View {
    var course: Course
    var firebase: Firebase
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var courseFolders: [Folder] = []
    @State private var directCourseNotes: [Note] = []
    @State private var folderToDelete: Folder?
    @State private var noteToDelete: Note?
    @State private var activeAlert: ActiveAlert?

    enum ActiveAlert: Identifiable {
        case deleteFolder, deleteNote

        var id: Int {
            switch self {
            case .deleteFolder: return 1
            case .deleteNote: return 2
            }
        }
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
            fetchFoldersForCourse()
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
                            deleteFolder(folder)
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

    private var recentNoteSummarySection: some View {
        if let recentNote = getMostRecentNoteForCourse() {
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
                        activeAlert = .deleteFolder
                    } label: {
                        Label("Delete Folder", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func fetchFoldersForCourse() {
        firebase.getFolders { allFolders in
            self.courseFolders = allFolders.filter { folder in
                course.folders.contains(folder.id ?? "")
            }
        }
    }

    private func fetchDirectNotesForCourse() {
        directCourseNotes = firebase.notes.filter { note in
            course.notes.contains(note.id ?? "")
        }
    }

    private func deleteFolder(_ folder: Folder) {
        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
            if let error = error {
                print("Error deleting folder: \(error.localizedDescription)")
            } else {
                fetchFoldersForCourse()
            }
        }
    }

    private func deleteDirectNote(_ note: Note) {
        firebase.deleteNote(note: note, folderID: nil) { error in
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                fetchDirectNotesForCourse()
            }
        }
    }

    private func getMostRecentNoteForCourse() -> Note? {
        let sortedNotes = directCourseNotes.sorted { $0.createdAt > $1.createdAt }
        return sortedNotes.first
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

