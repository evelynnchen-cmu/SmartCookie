



import SwiftUI
import Combine

class EditStates: ObservableObject {
    @Published var courseToEdit: Course?
    @Published var folderToEdit: Folder?
    @Published var noteToEdit: Note?
    @Published var showEditCourseModal = false
    @Published var showEditFolderModal = false
    @Published var showEditNoteModal = false
    @Published var showPlusActions = false
}

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

struct CourseView: View {
    var course: Course
    var firebase: Firebase
  @StateObject private var viewModel: CourseViewModel
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var courseFolders: [Folder] = []
    @State private var directCourseNotes: [Note] = []
    @State private var folderToDelete: Folder?
    @State private var noteToDelete: Note?
    @Binding var navigationPath: NavigationPath
    @State private var activeAlert: ActiveAlert?
    @StateObject private var editStates = EditStates()
  
  init(course: Course, firebase: Firebase, navigationPath: Binding<NavigationPath>) {
            self.course = course
            self.firebase = firebase
            self._navigationPath = navigationPath
          _viewModel = StateObject(wrappedValue: CourseViewModel(firebase: firebase, course: course))
  }

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
        ZStack {
            ScrollView {
              VStack(alignment: .leading, spacing: 8) {
                recentNoteSummarySection
                  .padding(.top)
                fileSection
              }
              .padding(.bottom, 80)
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
            .navigationDestination(for: Note.self) { note in
              NoteView(firebase: firebase, note: note, course: course)
            }
            .navigationDestination(for: Folder.self) { folder in
              FolderView(firebase: firebase, course: course, folderViewModel: FolderViewModel(firebase: firebase, folder: folder, course: course))
            }
            
            VStack {
            Spacer()
            
            HStack {
              Spacer()
                Button(action: {
                    editStates.showPlusActions = true
                }){
                  Image(systemName: "plus.square.fill")
                      .resizable()
                      .frame(width: 50, height: 50)
                      .foregroundColor(.black)
              }
            }
            .padding(.bottom, 20)
            .padding(.trailing, 20)
          }
        }
        .confirmationDialog("Create", isPresented: $editStates.showPlusActions, titleVisibility: .hidden) {
            Button("New Note") {
                isAddingNote = true
            }
            Button("New Folder") {
                isAddingFolder = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }

  private var recentNoteSummarySection: some View {
      VStack(alignment: .leading, spacing: 16) {

          Text(viewModel.course.courseName)
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.black)
              .padding(.horizontal)


          VStack(alignment: .leading, spacing: 8) {
              Text("Get caught up!")
                  .font(.title2)
                  .fontWeight(.semibold)
                  .foregroundColor(.black)
                  .padding(.horizontal)
              
              if let recentNote = viewModel.getMostRecentlyAccessedNote() {
                  VStack(alignment: .leading, spacing: 4) {

                      ZStack(alignment: .bottomTrailing) {
                          ScrollView {
                              Text(recentNote.summary)
                                  .font(.body)
                                  .foregroundColor(.black)
                                  .multilineTextAlignment(.leading)
                                  .padding()
                                  .padding(.bottom, 20)
                          }
                          
                          LinearGradient(
                              gradient: Gradient(colors: [.white.opacity(0), .white]),
                              startPoint: .top,
                              endPoint: .bottom
                          )
                          .frame(height: 30)
                          
                          Image(systemName: "chevron.down")
                              .foregroundColor(darkBrown.opacity(0.5))
                              .padding(.trailing, 12)
                              .padding(.bottom, 8)
                      }
                      .frame(maxWidth: .infinity)
                      .frame(height: UIScreen.main.bounds.height / 5)
                      .background(Color.white)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(darkBrown, lineWidth: 2)
                      )
                      
                      Text("Summary from \(dateFormatter.string(from: recentNote.createdAt))")
                          .font(.caption)
                          .foregroundColor(.gray)
                          .frame(maxWidth: .infinity, alignment: .trailing)
                  }
                  .padding(.horizontal)
              }
          }
      }
  }

  private var fileSection: some View {
      VStack(alignment: .leading, spacing: 16) {
//          Text("Files")
//              .font(.headline)
//              .padding(.top, 10)
//              .padding(.horizontal, 20)
//          
          LazyVGrid(
              columns: [
                  GridItem(.flexible()),
                  GridItem(.flexible()),
                  GridItem(.flexible()),
                  GridItem(.flexible())
              ],
              spacing: 20
          ) {
              ForEach(viewModel.folders, id: \.id) { folder in
                  NavigationLink(
                      destination: FolderView(
                          firebase: viewModel.firebase,
                          course: viewModel.course,
                          folderViewModel: FolderViewModel(firebase: viewModel.firebase, folder: folder, course: viewModel.course)
                      )
                  ) {
                      VStack(spacing: 8) {
                          Image(systemName: "folder.fill")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(width: 70, height: 70)
                              .foregroundColor(darkBrown)
                          Text(folder.folderName)
                              .font(.subheadline)
                              .lineLimit(2)
                              .multilineTextAlignment(.center)
                              .frame(height: 40)
                              .foregroundColor(.black)
                      }
                  }
                  .contextMenu {
                      Button(action: {
                          editStates.folderToEdit = folder
                          editStates.showEditFolderModal = true
                      }) {
                          Label("Edit Folder", systemImage: "pencil")
                      }
                      
                      Button(role: .destructive) {
                          folderToDelete = folder
                          activeAlert = .deleteFolder
                      } label: {
                          Label("Delete Folder", systemImage: "trash")
                      }
                  }
              }

              ForEach(viewModel.notes, id: \.id) { note in
                  NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note, course: viewModel.course)) {
                      VStack(spacing: 8) {
                          Image(systemName: "text.document.fill")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(width: 70, height: 70)
                              .foregroundColor(tan)
                          Text(note.title)
                              .font(.subheadline)
                              .lineLimit(2)
                              .multilineTextAlignment(.center)
                              .frame(height: 40)
                              .foregroundColor(.black)
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
                          activeAlert = .deleteNote
                      } label: {
                          Label("Delete Note", systemImage: "trash")
                      }
                  }
              }
          }
          .padding(.top, 10)
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



