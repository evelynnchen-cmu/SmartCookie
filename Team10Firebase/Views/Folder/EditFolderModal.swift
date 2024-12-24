//
//  EditFolderModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/2/24.
//

import SwiftUI
import FirebaseFirestore

struct EditFolderModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String
    let folder: Folder
    @ObservedObject var firebase: Firebase
    var onFolderUpdated: () -> Void
    
    init(folder: Folder, firebase: Firebase, onFolderUpdated: @escaping () -> Void) {
        self.folder = folder
        self.firebase = firebase
        self.onFolderUpdated = onFolderUpdated
        _newName = State(initialValue: folder.folderName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Information")) {
                    TextField("Folder Name", text: $newName)
                }
                
                Button("Update Folder") {
                    guard let folderID = folder.id else { return }
                    firebase.updateFolderName(folderID: folderID, newName: newName) { error in
                        if let error = error {
                            print("Error updating folder: \(error.localizedDescription)")
                        } else {
                            onFolderUpdated()
                            dismiss()
                        }
                    }
                }
                .disabled(newName.isEmpty || newName == folder.folderName)
            }
            .navigationTitle("Edit Folder")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
