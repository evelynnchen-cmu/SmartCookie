//
//  AddFolderModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/3/24.
//

import SwiftUI

struct FolderModal: View {
    @Environment(\.dismiss) var dismiss
    var onFolderCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course
    
    @State private var folderName: String = ""
    @State private var fileLocation: String = ""
    @State private var notes: [String] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Details")) {
                    TextField("Folder Name", text: $folderName)
                    TextField("File Location", text: $fileLocation)
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
        do {
            try await firebase.createFolder(
                folderName: folderName,
                course: course,
                notes: notes,
                fileLocation: fileLocation
            )
        } catch {
            print("Error creating folder: \(error.localizedDescription)")
        }
    }
}
