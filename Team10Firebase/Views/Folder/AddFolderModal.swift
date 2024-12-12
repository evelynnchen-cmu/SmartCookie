

import SwiftUI

struct AddFolderModal: View {
    @Environment(\.dismiss) var dismiss
    var onFolderCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    
    @State private var folderName: String = ""
    @State private var selectedFolder: Folder?
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Details")) {
                    TextField("Folder Name", text: $folderName)
                }
                
                Button("Create Folder") {
                    Task {
                        createFolder()
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
    
    private func createFolder() {
        guard let courseID = course.id else {
            print("Error: Missing course ID.")
            return
        }
        
        let fileLocation = "\(courseID)/"
        
        firebase.createFolder(
            folderName: folderName,
            course: course,
            notes: [],
            fileLocation: fileLocation
        ) { (newFolder, error) in
            if let error = error {
                print("Error creating folder: \(error.localizedDescription)")
            } else {
                if let newFolder = newFolder {
                    self.selectedFolder = newFolder
                    print("Selected folder: \(selectedFolder?.folderName ?? "nil")")
                    navigationPath.append(newFolder)
                }
            }
        }
    }
}

