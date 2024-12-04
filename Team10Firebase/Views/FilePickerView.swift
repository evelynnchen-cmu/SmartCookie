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
                    fetchFolders()
                    fetchNotes()
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
                Button("Back") { selectedFolder = nil }
            } else if selectedCourse != nil {
                Button("Back") { selectedCourse = nil }
            }
        }
    }

    private func notesInFolderSection(course: Course, folder: Folder) -> some View {
        Section(header: Text("Notes in \(folder.folderName ?? "Unnamed Folder")")) {
            // let notesInFolder = firebase.notes.filter {
            //     $0.courseID == course.id && $0.fileLocation.contains(folder.id ?? "") == true
            // }
            if notes.isEmpty {
                Text("No notes available").foregroundColor(.secondary)
            } else {
                ForEach(notes) { note in
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
            Section(header: Text("Folders in \(course.courseName)")) {
                let courseFolders = folders.filter { $0.courseID == course.id } // Use local folders state
                if courseFolders.isEmpty {
                    Text("No folders available").foregroundColor(.secondary)
                } else {
                    ForEach(courseFolders) { folder in
                        Button(action: {
                            selectedFolder = folder
                            fetchNotes()
                            print("Selected Folder: \(folder.folderName), ID: \(folder.id ?? "nil")")
                        }) {
                            Text(folder.folderName)
                        }
                    }
                }
            }

            Section(header: Text("Notes Not in a Folder")) {
                let courseNotes = firebase.notes.filter { $0.courseID == course.id && $0.fileLocation.isEmpty }
                if courseNotes.isEmpty {
                    Text("No notes available").foregroundColor(.secondary)
                } else {
                    ForEach(courseNotes) { note in
                        Button(action: {
                            selectedNote = note
                            print("Selected Note: \(note.title), ID: \(note.id ?? "nil")")
                        }) {
                            HStack {
                                Text(note.title)
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
        print("Fetching notes for selected course: \(selectedCourse?.courseName ?? "None")")
        guard let selectedCourse = selectedCourse else {
            print("No course selected.")
            notes = [] // Clear notes if no course selected
            return
        }

        if let selectedFolder = selectedFolder {
            // Fetch notes specifically in the selected folder
            // notes = firebase.notes.filter { note in
            //     note.courseID == selectedCourse.id && (note.fileLocation == "\(selectedCourse.id)/" || note.fileLocation.isEmpty)
            // }
            notes = firebase.notes.filter { note in
                guard let courseID = note.courseID else { return false }
                return courseID == selectedCourse.id
            }
            print("Notes in folder \(selectedFolder.folderName ?? "Unnamed"): \(notes.map { $0.title })")
        } else {
            // Fetch notes for the selected course not in any folder
            // notes = firebase.notes.filter { note in
                // note.courseID == selectedCourse.id &&
                // (note.fileLocation == "\(selectedCourse.id)/" || !note.fileLocation.contains("/"))
            // }
            notes = firebase.notes.filter { note in
                guard let courseID = note.courseID else { return false }
                return courseID == selectedCourse.id
            }
            print("selected course id: \(selectedCourse.id ?? "nil")")
            print("firebase notes: \(firebase.notes.map { $0.title })")
            print("firebase notes filtered by course id: \(firebase.notes.filter { $0.courseID == selectedCourse.id }.map { $0.title })")
            print("firebase notes filtered by course id and file location: \(firebase.notes.filter { $0.courseID == selectedCourse.id && $0.fileLocation == "\(selectedCourse.id)/" }.map { $0.title })")
            print("note.courseid: \(notes.map { $0.courseID })")
            print("note.filelocation: \(notes.map { $0.fileLocation })")
            print("Notes not in a folder for course \(selectedCourse.courseName): \(notes.map { $0.title })")
        }
    }

    private func debugPrintData() {
        print("Debugging Firebase Data:")
        print("Total Folders: \(folders.count)")
        print("Total Notes: \(firebase.notes.count)")
        
        for folder in folders {
            print("Folder Name: \(folder.folderName ?? "nil"), ID: \(folder.id ?? "nil"), CourseID: \(folder.courseID ?? "nil")")
        }
        for note in firebase.notes {
            print("Note Title: \(note.title ?? "nil"), CourseID: \(note.courseID ?? "nil"), FileLocation: \(note.fileLocation ?? "nil")")
        }
        for note in firebase.notes {
            print("Note FileLocation: \(note.fileLocation ?? "nil"), Expected Folder ID: \(selectedFolder?.id ?? "nil")")
        }
        for note in notes {
            print("Note Title for notes: \(note.title ?? "nil"), CourseID: \(note.courseID ?? "nil"), FileLocation: \(note.fileLocation ?? "nil")")
        }


        if let selectedCourse = selectedCourse {
            print("Selected Course: \(selectedCourse.courseName), ID: \(selectedCourse.id ?? "nil")")
            let courseFolders = firebase.folders.filter { $0.courseID == selectedCourse.id ?? "" }
            let courseNotes = firebase.notes.filter { $0.courseID == selectedCourse.id }
            print("Folders in Course: \(courseFolders.map { $0.folderName })")
            print("Notes in Course: \(courseNotes.map { $0.title })")
        }

        if let selectedFolder = selectedFolder {
            let notesInFolder = firebase.notes.filter { $0.fileLocation == selectedFolder.id }
            print("Notes in Selected Folder (\(selectedFolder.folderName)): \(notesInFolder.map { $0.title })")
        }
    }
}
