

import SwiftUI

struct CourseView: View {
    @StateObject private var firebase = Firebase()
    var course: Course
    @State private var isAddingFolder = false
    @State private var courseFolders: [Folder] = []
    @State private var folderToDelete: Folder?
    @State private var showDeleteFolderAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                courseDetailsSection
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
        .onAppear {
            fetchFoldersForCourse()
        }
        .navigationTitle(course.courseName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Folder") {
                    isAddingFolder = true
                }
            }
        }
        .alert(isPresented: $showDeleteFolderAlert) {
            Alert(
                title: Text("Delete Folder"),
                message: Text("Are you sure you want to delete this folder and all its notes?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let folder = folderToDelete {
                        firebase.deleteFolder(folder: folder, courseID: course.id ?? "") { error in
                            if let error = error {
                                print("Error deleting folder: \(error.localizedDescription)")
                            } else {
                                fetchFoldersForCourse() // Refresh folders after deletion
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
                NavigationLink(
                    destination: FolderView(
                        firebase: firebase,
                        folder: folder,
                        course: course
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
    
    private func fetchFoldersForCourse() {
        firebase.getFolders { allFolders in
            self.courseFolders = allFolders.filter { folder in
                course.folders.contains(folder.id ?? "")
            }
        }
    }
}

