
import SwiftUI

struct CourseView: View {
    @StateObject private var firebase = Firebase()
    var course: Course
    @State private var isAddingFolder = false
    @State private var courseFolders: [Folder] = []

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
                        firebase: firebase, // Pass firebase instance
                        folder: folder, // Pass the folder instance
                        course: course // Pass the course instance
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

