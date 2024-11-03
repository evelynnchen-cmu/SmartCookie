import SwiftUI

struct FolderView: View {
    var folder: Folder // Add a Folder property to accept the folder data

    var body: some View {
        VStack(alignment: .leading) {
            Text("Folder Name: \(folder.folderName)")
                .font(.title)
                .padding(.bottom, 2)
            
            Text("Course ID: \(folder.courseID)")
                .font(.body)
            
            if let userID = folder.userID {
                Text("User ID: \(userID)")
                    .font(.body)
            }
            
            Text("File Location: \(folder.fileLocation)")
                .font(.body)
            
            if let recentNoteSummary = folder.recentNoteSummary {
                Text("Recent Note Title: \(recentNoteSummary.title)")
                    .font(.body)
                Text("Summary: \(recentNoteSummary.summary)")
                    .font(.body)
            }
        }
        .padding()
        .navigationTitle("Folder Details")
    }
}

#Preview {
    FolderView(folder: Folder(
        id: "1",
        userID: "User123",
        folderName: "Sample Folder",
        courseID: "Course123",
        notes: [],
        fileLocation: "/path/to/file",
        recentNoteSummary: Folder.RecentNoteSummary(
            noteID: "Note1",
            title: "Sample Note",
            summary: "This is a sample summary.",
            createdAt: Date()
        )
    ))
}
