//
//  AddFolderModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 11/3/24.
//

import SwiftUI

struct AddFolderModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var folderName: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    var onFolderCreated: () -> Void
    @ObservedObject var firebase: Firebase
    var course: Course // Pass the course so that folder is associated with it
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Information")) {
                    TextField("Folder Name", text: $folderName)
                }
                
                Button("Create Folder") {
                    Task {
                        do {
                            try await firebase.createFolder(folderName: folderName, course: course) // Ensure correct order and labels
                            onFolderCreated()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }.disabled(folderName.isEmpty)
            }
            .navigationTitle("New Folder")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}
