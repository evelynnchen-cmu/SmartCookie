//
//import SwiftUI
//
//struct CourseView: View {
//    @StateObject private var firebase = Firebase()
//    var course: Course
//    @State private var isAddingNote = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading) {
//                    courseDetailsSection
//                    notesSection
//                }
//                .padding(.leading)
//            }
//            .navigationTitle(course.courseName)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add Note") {
//                        isAddingNote = true
//                    }
//                }
//            }
//            .sheet(isPresented: $isAddingNote) {
//                AddNoteModal(
//                    onNoteCreated: {
//                        firebase.getNotes()
//                    },
//                    firebase: firebase,
//                    course: course 
//                )
//            }
//            .onAppear {
//                firebase.getNotes()
//            }
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
//    private var notesSection: some View {
//        let courseNotes: [Note] = firebase.notes.filter { note in
//            course.notes.contains(note.id ?? "")
//        }
//
//        return VStack(alignment: .leading) {
//            ForEach(courseNotes, id: \.id) { note in
//                NavigationLink(destination: NoteView(note: note)) {
//                    Text(note.title)
//                        .font(.body)
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(8)
//                        .padding(.vertical, 2)
//                }
//            }
//        }
//    }
//}


import SwiftUI

struct CourseView: View {
    @StateObject private var firebase = Firebase()
    var course: Course
    @State private var isAddingFolder = false
    @State private var selectedFolder: Folder?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    courseDetailsSection
                    foldersSection
                }
                .padding(.leading)
            }
            .navigationTitle(course.courseName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Folder") {
                        isAddingFolder = true
                    }
                }
            }
            // Handle potential errors in the Task block with try and do-catch
            .sheet(isPresented: $isAddingFolder) {
                AddFolderModal(
                    firebase: firebase,
                    course: course,
                    onFolderCreated: {
                        Task {
                            do {
                                try await firebase.getFolders(for: course)
                            } catch {
                                print("Error fetching folders: \(error.localizedDescription)")
                            }
                        }
                    }
                )
            }
            .sheet(item: $selectedFolder) { folder in
                FolderView(folder: folder, firebase: firebase)
            }
            .onAppear {
                Task {
                    do {
                        try await firebase.getFolders(for: course)
                    } catch {
                        print("Error fetching folders on appear: \(error.localizedDescription)")
                    }
                }
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

    private var foldersSection: some View {
        VStack(alignment: .leading) {
            Text("Folders")
                .font(.headline)
                .padding(.bottom, 5)

            ForEach(firebase.folders, id: \.id) { folder in
                Button(action: {
                    selectedFolder = folder
                }) {
                    Text(folder.folderName)
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
