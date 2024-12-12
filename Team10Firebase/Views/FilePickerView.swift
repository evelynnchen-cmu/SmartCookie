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
                    firebase.getNotes()
                    firebase.getFolders { fetchedFolders in
                        folders = fetchedFolders
                        fetchNotes()
                    }
                    debugPrintData() 
                }
                .onChange(of: firebase.notes) { updatedNotes in
                    print("Firebase notes updated: \(updatedNotes.map { $0.title })")
                    fetchNotes()
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
                    fetchNotes()
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

    private func notesInFolderSection(course: Course, folder: Folder) -> some View {
        Section(header: Text("Notes in \(folder.folderName ?? "Unnamed Folder")")) {
            let notesInFolder = firebase.notes.filter { note in
                note.courseID == course.id && note.fileLocation == folder.id
            }
            
            if notesInFolder.isEmpty {
                Text("No notes available").foregroundColor(.secondary)
            } else {
                ForEach(notesInFolder) { note in
                    Button(action: {
                        selectedNote = note
                        print("Selected Note in Folder: \(note.title ?? "Unnamed Note"), ID: \(note.id ?? "nil")")
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


    private func foldersAndNotesSection(course: Course) -> some View {
        Group {
            let courseFolders = folders.filter { $0.courseID == course.id }
            
            // Folders section
            Section(header: Text("Folders")) {
                ForEach(courseFolders) { folder in
                    Button(action: {
                        selectedFolder = folder
                        print("Selected Folder: \(folder.folderName ?? "Unnamed Folder")")
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
                let uncategorizedNotes = firebase.notes.filter { 
                    $0.courseID == course.id && $0.fileLocation.isEmpty
                }
                
                if uncategorizedNotes.isEmpty {
                    Text("No uncategorized notes").foregroundColor(.secondary)
                } else {
                    ForEach(uncategorizedNotes) { note in
                        Button(action: {
                            selectedNote = note
                            print("Selected Note: \(note.title ?? "Unnamed Note")")
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


    private func coursesSection() -> some View {
        Section(header: Text("Courses")) {
            ForEach(firebase.courses) { course in
                Button(action: {
                    selectedCourse = course
                    selectedFolder = nil
                    fetchNotes()
                    print("Selected Course: \(course.courseName), ID: \(course.id ?? "nil")")
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

    private func fetchNotes() {
        guard let selectedCourse = selectedCourse else {
            print("No course selected.")
            notes = []
            return
        }
        
        if let selectedFolder = selectedFolder {
            // Get notes for the selected folder
            notes = firebase.notes.filter { 
                $0.courseID == selectedCourse.id && $0.fileLocation == selectedFolder.id 
            }
        } else {
            // Get all notes for the course
            notes = firebase.notes.filter { $0.courseID == selectedCourse.id }
        }
        print("Fetched notes for \(selectedFolder?.folderName ?? selectedCourse.courseName): \(notes.map { $0.title })")
    }


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
