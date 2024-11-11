//import SwiftUI
//
//struct CourseView: View {
//    @StateObject private var firebase = Firebase()
//    var course: Course
//    @State private var isAddingFolder = false
//    @State private var isAddingNote = false
//    @State private var courseFolders: [Folder] = []
//    @State private var folderToDelete: Folder?
//    @State private var showDeleteFolderAlert = false
//    @State private var directCourseNotes: [Note] = [] // Only notes directly in the course
//    @State private var noteToDelete: Note? // Track the note to be deleted
//    @State private var showDeleteNoteAlert = false // Alert for deleting note
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                courseDetailsSection
//                recentNoteSummarySection
//                directNotesSection
//                foldersSection
//            }
//            .padding(.leading)
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
//                folder: nil // Adds note directly to course
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
//        .alert(isPresented: $showDeleteFolderAlert) {
//            Alert(
//                title: Text("Delete Folder"),
//                message: Text("Are you sure you want to delete this folder and all its notes?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let folder = folderToDelete {
//                        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
//                            if let error = error {
//                                print("Error deleting folder: \(error.localizedDescription)")
//                            } else {
//                                fetchFoldersForCourse()
//                            }
//                        }
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//        .alert(isPresented: $showDeleteNoteAlert) {
//            Alert(
//                title: Text("Delete Note"),
//                message: Text("Are you sure you want to delete this note?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let note = noteToDelete {
//                        deleteDirectNote(note)
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    private var courseDetailsSection: some View {
//        VStack(alignment: .leading) {
//            Text("Course ID: \(course.id ?? "N/A")")
//                .font(.body)
//            Text("User ID: \(course.userID)")
//                .font(.body)
//            Text(course.courseName)
//                .font(.body)
//            Text("Folders: \(course.folders.joined(separator: ", "))")
//                .font(.body)
//            Text("File Location: \(course.fileLocation)")
//                .font(.body)
//        }
//    }
//
//    private var recentNoteSummarySection: some View {
//        if let recentNote = getMostRecentNoteForCourse(courseID: course.id!) {
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
//                NavigationLink(destination: NoteView(firebase: firebase, note: note)) {
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
//                        showDeleteNoteAlert = true
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
//                        folder: folder,
//                        course: course
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
//                        showDeleteFolderAlert = true
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
//        firebase.getNotes()
//        directCourseNotes = firebase.notes.filter { note in
//            course.notes.contains(note.id ?? "")
//        }
//    }
//
//    private func deleteDirectNote(_ note: Note) {
//        guard let noteID = note.id else { return }
//        firebase.deleteNote(note: note, folderID: nil) { error in
//            if let error = error {
//                print("Error deleting note: \(error.localizedDescription)")
//            } else {
//                // Update the notes list after deletion
//                fetchDirectNotesForCourse()
//            }
//        }
//    }
//
//    private func getMostRecentNoteForCourse(courseID: String) -> Note? {
//        let filteredNotes = directCourseNotes // Only consider notes directly in the course
//        let sortedNotes = filteredNotes.sorted { $0.createdAt > $1.createdAt }
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








//import SwiftUI
//
//struct CourseView: View {
//    @StateObject private var viewModel: CourseViewModel
//    @State private var isAddingFolder = false
//    @State private var isAddingNote = false
//    @State private var folderToDelete: Folder?
//    @State private var showDeleteFolderAlert = false
//    @State private var noteToDelete: Note?
//    @State private var showDeleteNoteAlert = false
//    
//    init(course: Course) {
//        _viewModel = StateObject(wrappedValue: CourseViewModel(course: course))
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                courseDetailsSection
//                recentNoteSummarySection
//                directNotesSection
//                foldersSection
//            }
//            .padding(.leading)
//        }
//        .sheet(isPresented: $isAddingFolder) {
//            FolderModal(
//                onFolderCreated: {
//                    viewModel.fetchFoldersForCourse()
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course
//            )
//        }
//        .sheet(isPresented: $isAddingNote) {
//            AddNoteModal(
//                onNoteCreated: {
//                    viewModel.fetchDirectNotesForCourse()
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course,
//                folder: nil
//            )
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
//        .alert(isPresented: $showDeleteFolderAlert) {
//            Alert(
//                title: Text("Delete Folder"),
//                message: Text("Are you sure you want to delete this folder and all its notes?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let folder = folderToDelete {
//                        viewModel.deleteFolder(folder) { error in
//                            if let error = error {
//                                print("Error deleting folder: \(error.localizedDescription)")
//                            } else {
//                                viewModel.fetchFoldersForCourse()
//                            }
//                        }
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//        .alert(isPresented: $showDeleteNoteAlert) {
//            Alert(
//                title: Text("Delete Note"),
//                message: Text("Are you sure you want to delete this note?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let note = noteToDelete {
//                        viewModel.deleteDirectNote(note) { error in
//                            if let error = error {
//                                print("Error deleting note: \(error.localizedDescription)")
//                            } else {
//                                viewModel.fetchDirectNotesForCourse()
//                            }
//                        }
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    private var courseDetailsSection: some View {
//        VStack(alignment: .leading) {
//            Text("Course ID: \(viewModel.course.id ?? "N/A")")
//                .font(.body)
//            Text("User ID: \(viewModel.course.userID)")
//                .font(.body)
//            Text(viewModel.course.courseName)
//                .font(.body)
//            Text("Folders: \(viewModel.course.folders.joined(separator: ", "))")
//                .font(.body)
//            Text("File Location: \(viewModel.course.fileLocation)")
//                .font(.body)
//        }
//    }
//
//    private var recentNoteSummarySection: some View {
//        if let recentNote = viewModel.getMostRecentNoteForCourse() {
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
//            ForEach(viewModel.directCourseNotes, id: \.id) { note in
//                NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note)) {
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
//                        showDeleteNoteAlert = true
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
//            ForEach(viewModel.courseFolders, id: \.id) { folder in
//                NavigationLink(
//                    destination: FolderView(
//                        firebase: viewModel.firebase,
//                        folder: folder,
//                        course: viewModel.course
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
//                        showDeleteFolderAlert = true
//                    } label: {
//                        Label("Delete Folder", systemImage: "trash")
//                    }
//                }
//            }
//        }
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





//import SwiftUI
//
//struct CourseView: View {
//    @StateObject private var viewModel: CourseViewModel
//    @State private var isAddingFolder = false
//    @State private var isAddingNote = false
//    @State private var folderToDelete: Folder?
//    @State private var showDeleteFolderAlert = false
//    @State private var noteToDelete: Note?
//    @State private var showDeleteNoteAlert = false
//    
//    init(course: Course) {
//        _viewModel = StateObject(wrappedValue: CourseViewModel(course: course))
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                courseDetailsSection
//                recentNoteSummarySection
//                directNotesSection
//                foldersSection
//            }
//            .padding(.leading)
//        }
//        .sheet(isPresented: $isAddingFolder) {
//            FolderModal(
//                onFolderCreated: {
//                    // No need for manual fetch; observeFolderUpdates in viewModel takes care of it
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course
//            )
//        }
//        .sheet(isPresented: $isAddingNote) {
//            AddNoteModal(
//                onNoteCreated: {
//                    viewModel.fetchDirectNotesForCourse() // Refresh notes after adding
//                },
//                firebase: viewModel.firebase,
//                course: viewModel.course,
//                folder: nil
//            )
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
//        .alert(isPresented: $showDeleteFolderAlert) {
//            Alert(
//                title: Text("Delete Folder"),
//                message: Text("Are you sure you want to delete this folder and all its notes?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let folder = folderToDelete {
//                        viewModel.deleteFolder(folder) { error in
//                            if let error = error {
//                                print("Error deleting folder: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//        .alert(isPresented: $showDeleteNoteAlert) {
//            Alert(
//                title: Text("Delete Note"),
//                message: Text("Are you sure you want to delete this note?"),
//                primaryButton: .destructive(Text("Delete")) {
//                    if let note = noteToDelete {
//                        viewModel.deleteDirectNote(note) { error in
//                            if let error = error {
//                                print("Error deleting note: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    private var courseDetailsSection: some View {
//        VStack(alignment: .leading) {
//            Text("Course ID: \(viewModel.course.id ?? "N/A")")
//                .font(.body)
//            Text("User ID: \(viewModel.course.userID)")
//                .font(.body)
//            Text(viewModel.course.courseName)
//                .font(.body)
//            Text("Folders: \(viewModel.course.folders.joined(separator: ", "))")
//                .font(.body)
//            Text("File Location: \(viewModel.course.fileLocation)")
//                .font(.body)
//        }
//    }
//
//    private var recentNoteSummarySection: some View {
//        if let recentNote = viewModel.getMostRecentNoteForCourse() {
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
//            ForEach(viewModel.directCourseNotes, id: \.id) { note in
//                NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note)) {
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
//                        showDeleteNoteAlert = true
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
//            ForEach(viewModel.courseFolders, id: \.id) { folder in
//                NavigationLink(
//                    destination: FolderView(
//                        firebase: viewModel.firebase,
//                        folder: folder,
//                        course: viewModel.course
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
//                        showDeleteFolderAlert = true
//                    } label: {
//                        Label("Delete Folder", systemImage: "trash")
//                    }
//                }
//            }
//        }
//    }
//}
//
//private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .short
//    return formatter
//}()


import SwiftUI

struct CourseView: View {
    @StateObject private var viewModel: CourseViewModel
    @State private var isAddingFolder = false
    @State private var isAddingNote = false
    @State private var folderToDelete: Folder?
    @State private var showDeleteFolderAlert = false
    @State private var noteToDelete: Note?
    @State private var showDeleteNoteAlert = false
    
    init(course: Course) {
        _viewModel = StateObject(wrappedValue: CourseViewModel(course: course))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                courseDetailsSection
                recentNoteSummarySection
                directNotesSection
                foldersSection
            }
            .padding(.leading)
            .onAppear {
                viewModel.listenToFolders()
                viewModel.listenToDirectNotes()
            }
        }
        .sheet(isPresented: $isAddingFolder) {
            FolderModal(
                onFolderCreated: {
                    isAddingFolder = false // Close the sheet after creating
                },
                firebase: viewModel.firebase,
                course: viewModel.course
            )
        }
        .sheet(isPresented: $isAddingNote) {
            AddNoteModal(
                onNoteCreated: {
                    isAddingNote = false // Close the sheet after creating
                },
                firebase: viewModel.firebase,
                course: viewModel.course,
                folder: nil
            )
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
        .alert(isPresented: $showDeleteFolderAlert) {
            Alert(
                title: Text("Delete Folder"),
                message: Text("Are you sure you want to delete this folder and all its notes?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let folder = folderToDelete {
                        viewModel.deleteFolder(folder) { error in
                            if let error = error {
                                print("Error deleting folder: \(error.localizedDescription)")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showDeleteNoteAlert) {
            Alert(
                title: Text("Delete Note"),
                message: Text("Are you sure you want to delete this note?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let note = noteToDelete {
                        viewModel.deleteDirectNote(note) { error in
                            if let error = error {
                                print("Error deleting note: \(error.localizedDescription)")
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var courseDetailsSection: some View {
        VStack(alignment: .leading) {
            Text("Course ID: \(viewModel.course.id ?? "N/A")")
                .font(.body)
            Text("User ID: \(viewModel.course.userID)")
                .font(.body)
            Text(viewModel.course.courseName)
                .font(.body)
            Text("Folders: \(viewModel.course.folders.joined(separator: ", "))")
                .font(.body)
            Text("File Location: \(viewModel.course.fileLocation)")
                .font(.body)
        }
    }

    private var recentNoteSummarySection: some View {
        if let recentNote = viewModel.getMostRecentNoteForCourse() {
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
            
            ForEach(viewModel.directCourseNotes, id: \.id) { note in
                NavigationLink(destination: NoteView(firebase: viewModel.firebase, note: note)) {
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
        }
        .padding(.top, 10)
    }

    private var foldersSection: some View {
        VStack(alignment: .leading) {
            Text("Folders")
                .font(.headline)
            
            ForEach(viewModel.courseFolders, id: \.id) { folder in
                NavigationLink(
                    destination: FolderView(
                        firebase: viewModel.firebase,
                        folder: folder,
                        course: viewModel.course
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
                        showDeleteFolderAlert = true
                    } label: {
                        Label("Delete Folder", systemImage: "trash")
                    }
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
