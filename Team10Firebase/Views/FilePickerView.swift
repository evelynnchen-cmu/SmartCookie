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
                    leading: Button("Cancel") {
                        selectedNote = nil // Reset selectedNote when Cancel is tapped
                        isPresented = false // Close the modal
                    },
                    trailing: saveButton
                )
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
        .listStyle(InsetGroupedListStyle())
    }

    private func currentTitle() -> String {
        if let folder = selectedFolder { return folder.folderName }
        if let course = selectedCourse { return course.courseName }
        return "Select Course"
    }

    private var saveButton: some View {
        Button(action: {
            isPresented = false // Dismiss the view without modifying selectedNote
        }) {
            Image(systemName: selectedNote == nil ? "square.and.arrow.down" : "square.and.arrow.down.fill")
                .foregroundColor(selectedNote == nil ? .gray : darkBlue)
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") { 
                selectedNote = nil // Reset selectedNote when cancel is tapped
                isPresented = false // Close the modal
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
              let courseId = selectedCourse.id else {
            notes = []
            return
        }

        let notesToUse = !firebase.notes.isEmpty ? firebase.notes : localNotes

        if let selectedFolder = selectedFolder,
           let folderId = selectedFolder.id {
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

            Section(header: Text("Folders").foregroundColor(darkBlue)) {
                ForEach(courseFolders) { folder in
                    Button(action: {
                        selectedFolder = folder
                        updateFilteredNotes()
                    }) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(darkBlue)
                            Text(folder.folderName)
                                .foregroundColor(darkBlue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(darkBlue)
                        }
                    }
                }
            }

            Section(header: Text("Notes").foregroundColor(darkBlue)) {
                let uncategorizedNotes = notesToUse.filter { note in
                    note.courseID == courseId &&
                    (note.fileLocation == courseId ||
                     note.fileLocation == "\(courseId)/" ||
                     note.fileLocation.isEmpty)
                }

                if uncategorizedNotes.isEmpty {
                    Text("No uncategorized notes")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(uncategorizedNotes) { note in
                        noteButton(note: note)
                    }
                }
            }
        }
    }

    private func notesInFolderSection(course: Course, folder: Folder) -> some View {
        Section(header: Text("Notes in \(folder.folderName ?? "Unnamed Folder")").foregroundColor(darkBlue)) {
            let notesInFolder = notes.filter { note in
                note.courseID == course.id && 
                (note.fileLocation == "\(course.id ?? "")/\(folder.id ?? "")" || 
                note.fileLocation == folder.id)
            }

            if notesInFolder.isEmpty {
                Text("No notes available")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(notesInFolder) { note in
                    noteButton(note: note)
                }
            }
        }
    }

    private func noteButton(note: Note) -> some View {
        Button(action: {
            selectedNote = note
        }) {
            HStack {
                Text(note.title ?? "Unnamed Note")
                    .foregroundColor(darkBlue)
                    .fontWeight(selectedNote?.id == note.id ? .bold : .regular)
                Spacer()
            }
        }
    }

    private func coursesSection() -> some View {
        Section(header: Text("Courses").foregroundColor(darkBlue)) {
            ForEach(firebase.courses) { course in
                Button(action: {
                    selectedCourse = course
                    selectedFolder = nil
                    updateFilteredNotes()
                }) {
                    HStack {
                        Text(course.courseName)
                            .foregroundColor(darkBlue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(darkBlue)
                    }
                }
            }
        }
    }
}
