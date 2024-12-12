

import SwiftUI

struct FolderModal: View {
    @Environment(\.dismiss) var dismiss
    var onFolderCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    
    @State private var folderName: String = ""
    @State private var notes: [String] = []
    @State private var showAddNoteModal = false
    @State private var selectedFolder: Folder?
    
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
                
                Button("Add Note") {
                    showAddNoteModal = true
                }
                .disabled(selectedFolder == nil)
                .sheet(isPresented: $showAddNoteModal) {
                    if let folder = selectedFolder {
                        AddNoteModal(
                            onNoteCreated: {
                                firebase.getFolders { _ in }
                            },
                            firebase: firebase,
                            course: course,
                            folder: folder
                        )
                    }
                }
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
        
        let fileLocation = "\(courseID)/"
        
        do {
            try await firebase.createFolder(
                folderName: folderName,
                course: course,
                notes: notes,
                fileLocation: fileLocation
            )
            
            firebase.getFolders { folders in
                self.selectedFolder = folders.first { $0.folderName == folderName && $0.courseID == courseID }
            }
        } catch {
            print("Error creating folder: \(error.localizedDescription)")
        }
    }
}

