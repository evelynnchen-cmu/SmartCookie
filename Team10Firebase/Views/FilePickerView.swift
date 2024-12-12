//
//  FilePickerView.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/04/24.
//

import SwiftUI

struct FilePickerView: View {
    @ObservedObject var firebase: Firebase
    @Binding var isPresented: Bool
    @Binding var selectedNote: Note?

    @State private var selectedCourse: Course?
    @State private var selectedFolder: Folder?
    @State private var folders: [Folder] = []
    @State private var notes: [Note] = []
    @State private var localNotes: [Note] = []

    var body: some View {
        NavigationStack {
            contentList
                .navigationTitle(currentTitle())
                .navigationBarItems(
                    leading: Button("Cancel") { isPresented = false },
                    trailing: saveButton
                )
                .toolbar { toolbarContent }
                .onAppear {
                    loadNotesIfNeeded()
                    loadFoldersIfNeeded()
                }
                .onChange(of: firebase.notes) { newNotes in
                    if !newNotes.isEmpty {
                        localNotes = newNotes
                        updateFilteredNotes()
                    }
                }
        }
    }

    private var contentList: some View {
        List {
            if let course = selectedCourse {
                if let folder = selectedFolder {
                    notesInFolderSection(course: course, folder: folder)
                } else {
                    foldersAndNotesSection(course: course)
                }
            } else {
                coursesSection()
            }
        }
    }

    private func currentTitle() -> String {
        if let folder = selectedFolder { return folder.folderName }
        if let course = selectedCourse { return course.courseName }
        return "Select Note"
    }

    private var saveButton: some View {
        Group {
            if selectedFolder != nil {
                Button("Save") {
                    isPresented = false
                }
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if selectedFolder != nil {
                Button("Back") { 
                    selectedFolder = nil
                    selectedNote = nil
                    updateFilteredNotes()
                }
            } else if selectedCourse != nil {
                Button("Back") { 
                    selectedCourse = nil
                    selectedNote = nil
                    notes = []
                }
            }
        }
    }

    private func loadNotesIfNeeded() {
        if firebase.notes.isEmpty && localNotes.isEmpty {
            firebase.getNotes()
        } else if !firebase.notes.isEmpty && localNotes.isEmpty {
            localNotes = firebase.notes
            updateFilteredNotes()
        }
    }

    private func loadFoldersIfNeeded() {
        if folders.isEmpty {
            firebase.getFolders { fetchedFolders in
                folders = fetchedFolders
                updateFilteredNotes()
            }
        }
    }

    private func updateFilteredNotes() {
        guard let selectedCourse = selectedCourse,
            let courseId = selectedCourse.id else { // Safely unwrap courseId
            notes = []
            return
        }

        let notesToUse = !firebase.notes.isEmpty ? firebase.notes : localNotes
                
        if let selectedFolder = selectedFolder,
        let folderId = selectedFolder.id { // Safely unwrap folderId
            let expectedPath1 = "\(courseId)/\(folderId)"
            let expectedPath2 = folderId
            
            notes = notesToUse.filter { note in
                note.courseID == courseId &&
                (note.fileLocation == expectedPath1 ||
                note.fileLocation == expectedPath2)
            }
        } else {
            let expectedPaths = [
                courseId,
                "\(courseId)/",
                ""
            ]
            
            notes = notesToUse.filter { note in
                note.courseID == courseId &&
                (note.fileLocation.isEmpty ||
                expectedPaths.contains(note.fileLocation))
            }
        }
    }

    private func foldersAndNotesSection(course: Course) -> some View {
        Group {
            let courseFolders = folders.filter { $0.courseID == course.id }
            let notesToUse = !firebase.notes.isEmpty ? firebase.notes : localNotes
            let courseId = course.id ?? ""

            // Folders section
            Section(header: Text("Folders")) {
                ForEach(courseFolders) { folder in
                    Button(action: {
                        selectedFolder = folder
                        updateFilteredNotes()
                    }) {
                        HStack {
                            Image(systemName: "folder")
                            Text(folder.folderName)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            
            // Uncategorized notes section
            Section(header: Text("Notes")) {
                let uncategorizedNotes = notesToUse.filter { note in
                    note.courseID == courseId &&
                    (note.fileLocation == courseId ||
                    note.fileLocation == "\(courseId)/" ||
                    note.fileLocation.isEmpty)
                }

                if uncategorizedNotes.isEmpty {
                    Text("No uncategorized notes").foregroundColor(.secondary)
                } else {
                    ForEach(uncategorizedNotes) { note in
                        Button(action: {
                            selectedNote = note
                        }) {
                            HStack {
                                Text(note.title ?? "Unnamed Note")
                                if selectedNote?.id == note.id {
                                    Spacer()
                                    Image(systemName: "checkmark").foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func notesInFolderSection(course: Course, folder: Folder) -> some View {
        Section(header: Text("Notes in \(folder.folderName ?? "Unnamed Folder")")) {
            let notesToUse = !firebase.notes.isEmpty ? firebase.notes : localNotes
            let courseId = course.id ?? ""
            let folderId = folder.id ?? ""
            
            let notesInFolder = notesToUse.filter { note in
                note.courseID == courseId &&
                (note.fileLocation == "\(courseId)/\(folderId)" ||
                note.fileLocation == folderId)
            }

            if notesInFolder.isEmpty {
                Text("No notes available").foregroundColor(.secondary)
            } else {
                ForEach(notesInFolder) { note in
                    Button(action: {
                        selectedNote = note
                    }) {
                        HStack {
                            Text(note.title ?? "Unnamed Note")
                            if selectedNote?.id == note.id {
                                Spacer()
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
    }

    private func coursesSection() -> some View {
        Section(header: Text("Courses")) {
            ForEach(firebase.courses) { course in
                Button(action: {
                    selectedCourse = course
                    selectedFolder = nil
                    updateFilteredNotes()
                }) {
                    Text(course.courseName)
                }
            }
        }
    }

    private func fetchFolders() {
        firebase.getFolders { fetchedFolders in
            folders = fetchedFolders
        }
    }
}
