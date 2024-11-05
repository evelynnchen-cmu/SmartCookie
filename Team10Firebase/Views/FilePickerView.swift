import SwiftUI

struct FilePickerView: View {
    @ObservedObject var firebase: Firebase
    @Binding var isPresented: Bool
    @Binding var selectedNote: Note?

    @State private var selectedCourse: Course?
    @State private var selectedFolder: Folder?

    var body: some View {
//      using NavigationView and its not doubling the main nav bar
        NavigationView {
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
                        Button(action: {
                            selectedCourse = course
                        }) {
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
