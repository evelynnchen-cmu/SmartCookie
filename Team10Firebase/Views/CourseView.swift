

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
            .sheet(isPresented: $isAddingFolder) {
                FolderModal(
                    onFolderCreated: {
                        firebase.getFolders() // Refresh folders after adding a new one
                    },
                    firebase: firebase,
                    course: course
                )
            }
            .onAppear {
                firebase.getFolders()
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
        let courseFolders: [Folder] = firebase.folders.filter { folder in
            course.folders.contains(folder.id ?? "")
        }

        return VStack(alignment: .leading) {
            ForEach(courseFolders, id: \.id) { folder in
                NavigationLink(destination: FolderView(folder: folder)) {
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
