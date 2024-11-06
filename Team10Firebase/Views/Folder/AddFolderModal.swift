


import SwiftUI

struct FolderModal: View {
    @Environment(\.dismiss) var dismiss
    var onFolderCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    
    @State private var folderName: String = ""
    @State private var notes: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Details")) {
                    TextField("Folder Name", text: $folderName)
                }
                
                Button("Create Folder") {
                    Task {
                        await createFolder()
                        onFolderCreated()
                        dismiss()
                    }
                }
                .disabled(folderName.isEmpty)
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createFolder() async {
        guard let courseID = course.id else {
            print("Error: Missing course ID.")
            return
        }
        
        let fileLocation = "\(courseID)/" // Automatically set fileLocation based on courseID
        
        do {
            try await firebase.createFolder(
                folderName: folderName,
                course: course,
                notes: notes,
                fileLocation: fileLocation // Pass the automatically generated fileLocation
            )
        } catch {
            print("Error creating folder: \(error.localizedDescription)")
        }
    }
}

