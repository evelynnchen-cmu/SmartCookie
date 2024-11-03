//
//
//
//import SwiftUI
//
//struct CourseView: View {
//    @StateObject private var firebase = Firebase()
//    var course: Course
//    @State private var isAddingFolder = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading) {
//                    courseDetailsSection
//                    foldersSection
//                }
//                .padding(.leading)
//            }
//            .navigationTitle(course.courseName)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Add Folder") {
//                        isAddingFolder = true
//                    }
//                }
//            }
//            .sheet(isPresented: $isAddingFolder) {
//                FolderModal(
//                    onFolderCreated: {
//                        firebase.getFolders() // Refresh folders after adding a new one
//                    },
//                    firebase: firebase,
//                    course: course
//                )
//            }
//            .onAppear {
//                firebase.getFolders()
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
//    private var foldersSection: some View {
//        let courseFolders: [Folder] = firebase.folders.filter { folder in
//            course.folders.contains(folder.id ?? "")
//        }
//
//        return VStack(alignment: .leading) {
//            ForEach(courseFolders, id: \.id) { folder in
//                NavigationLink(destination: FolderView(folder: folder)) {
//                    Text(folder.folderName)
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
//


import SwiftUI

struct CourseView: View {
    @StateObject private var firebase = Firebase()
    var course: Course
    @State private var isAddingFolder = false
    @State private var courseFolders: [Folder] = []

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
                        fetchFoldersForCourse()
                    },
                    firebase: firebase,
                    course: course
                )
            }
            .onAppear {
                fetchFoldersForCourse()
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
    
    // Fetch folders that are associated with this course
    private func fetchFoldersForCourse() {
        firebase.getFolders { allFolders in
            self.courseFolders = allFolders.filter { folder in
                course.folders.contains(folder.id ?? "")
            }
        }
    }
}

