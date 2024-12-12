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
                        print("Updating local notes cache with \(newNotes.count) notes")
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
                    print("Save button pressed. Selected Folder: \(selectedFolder?.folderName ?? "nil")")
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
            print("Loading notes from Firebase...")
            firebase.getNotes()
        } else if !firebase.notes.isEmpty && localNotes.isEmpty {
            print("Caching \(firebase.notes.count) notes locally")
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

        print("\nDebug - Course Info:")
        print("Selected Course ID: \(courseId)")

        let notesToUse = !firebase.notes.isEmpty ? firebase.notes : localNotes
        print("Total notes to filter: \(notesToUse.count)")
        
        // Print all notes for this course to debug
        let allCourseNotes = notesToUse.filter { $0.courseID == courseId }
        print("Notes with matching courseID: \(allCourseNotes.count)")
        allCourseNotes.forEach { note in
            print("Note: \(note.title ?? ""), Location: '\(note.fileLocation)'")
        }
        
        if let selectedFolder = selectedFolder,
        let folderId = selectedFolder.id { // Safely unwrap folderId
            let expectedPath1 = "\(courseId)/\(folderId)"
            let expectedPath2 = folderId
            print("Looking for notes with paths: '\(expectedPath1)' or '\(expectedPath2)'")
            
            notes = notesToUse.filter { note in
                note.courseID == courseId &&
                (note.fileLocation == expectedPath1 ||
                note.fileLocation == expectedPath2)
            }
            print("Filtered \(notes.count) notes for folder \(selectedFolder.folderName ?? "")")
        } else {
            let expectedPaths = [
                courseId,
                "\(courseId)/",
                ""
            ]
            print("Looking for notes with paths: \(expectedPaths)")
            
            notes = notesToUse.filter { note in
                note.courseID == courseId &&
                (note.fileLocation.isEmpty ||
                expectedPaths.contains(note.fileLocation))
            }
            print("Filtered \(notes.count) uncategorized notes for course \(selectedCourse.courseName)")
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
                    print("\nSelected Course: \(course.courseName)")
                    print("Course ID: \(course.id)")
                    updateFilteredNotes() // Use updateFilteredNotes instead of fetchNotes
                }) {
                    Text(course.courseName)
                }
            }
        }
    }

    private func fetchFolders() {
        firebase.getFolders { fetchedFolders in
            folders = fetchedFolders // Update local folders state
        }
    }

    // private func fetchNotes() {
    //     guard let selectedCourse = selectedCourse else {
    //         print("No course selected.")
    //         notes = []
    //         return
    //     }
                
    //     if let selectedFolder = selectedFolder {
    //         notes = firebase.notes.filter { note in
    //             let matches = note.courseID == selectedCourse.id &&
    //                 (note.fileLocation == "\(selectedCourse.id)/\(selectedFolder.id)" ||
    //                  note.fileLocation == selectedFolder.id)
    //             if matches {
    //                 print("Matched note in folder: \(note.title ?? "")")
    //             }
    //             return matches
    //         }
    //     } else {
    //         notes = firebase.notes.filter { note in
    //             let matches = note.courseID == selectedCourse.id &&
    //                 (note.fileLocation == "\(selectedCourse.id)/" ||
    //                  note.fileLocation == "\(selectedCourse.id)" ||
    //                  note.fileLocation.isEmpty)
    //             if matches {
    //                 print("Matched uncategorized note: \(note.title ?? "")")
    //             }
    //             return matches
    //         }
    //     }
        
    //     print("Found \(notes.count) notes")
    // }

    private func debugPrintData() {
        print("Debugging Firebase Data:")
        print("Total Courses: \(firebase.courses.count)")
        print("Total Folders: \(folders.count)")
        print("Total Notes: \(firebase.notes.count)")
        
        print("\nFolders:")
        for folder in folders {
            print("Folder Name: \(folder.folderName ?? "nil"), ID: \(folder.id ?? "nil"), CourseID: \(folder.courseID ?? "nil")")
        }
        
        print("\nNotes:")
        for note in firebase.notes {
            print("Note Title: \(note.title ?? "nil"), CourseID: \(note.courseID ?? "nil"), FileLocation: \(note.fileLocation ?? "nil")")
        }
        
        // Cross-check notes and folders
        for folder in folders {
            let notesInFolder = firebase.notes.filter { $0.fileLocation == folder.id }
            print("Folder '\(folder.folderName ?? "nil")' contains notes: \(notesInFolder.map { $0.title ?? "nil" })")
        }
    }
}
