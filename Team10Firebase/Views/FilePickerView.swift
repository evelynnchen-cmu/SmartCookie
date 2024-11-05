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

    var body: some View {
//      using NavigationView and its not doubling the main nav bar
        NavigationStack {
            List {
                if let selectedCourse = selectedCourse {
                    if let selectedFolder = selectedFolder {
                        ForEach(firebase.notes.filter { $0.courseID == selectedCourse.id && $0.fileLocation == selectedFolder.id }) { note in
                            Button(action: {
                                selectedNote = note
                                isPresented = false
                            }) {
                                Text(note.title)
                            }
                        }
                    } else {
                        ForEach(firebase.folders.filter { $0.courseID == selectedCourse.id }) { folder in
                            Button(action: {
                                selectedFolder = folder
                            }) {
                                Text(folder.folderName)
                            }
                        }
                        ForEach(firebase.notes.filter { $0.courseID == selectedCourse.id && $0.fileLocation.isEmpty }) { note in
                            Button(action: {
                                selectedNote = note
                                isPresented = false
                            }) {
                                Text(note.title)
                            }
                        }
                    }
                } else {
                    ForEach(firebase.courses) { course in
                        NavigationLink(destination: CourseNotesView(course: course, firebase: firebase, selectedNote: $selectedNote, isPresented: $isPresented)) {
                            Text(course.courseName)
                        }
                    }
                }
            }
            .navigationTitle("Select Note")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

struct CourseNotesView: View {
    let course: Course
    @ObservedObject var firebase: Firebase
    @Binding var selectedNote: Note?
    @Binding var isPresented: Bool
    @State private var selectedFolder: Folder?

    var body: some View {
        List {
            if let selectedFolder = selectedFolder {
                ForEach(firebase.notes.filter { $0.courseID == course.id && $0.fileLocation == selectedFolder.id }) { note in
                    Button(action: {
                        selectedNote = note
                        isPresented = false
                    }) {
                        Text(note.title)
                    }
                }
            } else {
                ForEach(firebase.folders.filter { $0.courseID == course.id }) { folder in
                    Button(action: {
                        selectedFolder = folder
                    }) {
                        Text(folder.folderName)
                    }
                }
                ForEach(firebase.notes.filter { $0.courseID == course.id && $0.fileLocation.isEmpty }) { note in
                    Button(action: {
                        selectedNote = note
                        isPresented = false
                    }) {
                        Text(note.title)
                    }
                }
            }
        }
        .navigationTitle(course.courseName)
    }
}