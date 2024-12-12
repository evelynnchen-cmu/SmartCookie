import SwiftUI
import FirebaseFirestore

struct AddNoteModalCourse: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var images: [String] = []
    @State private var showError = false
    @State private var errorMessage: String = ""
    @State private var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @State private var courses: [Course] = []
    @State private var courseName = ""
    
    @ObservedObject var firebase: Firebase
    @State var course: Course?
    @State var courseFolders: [Folder] = []
    var folder: Folder? // Optional, if provided, note is added to this folder; otherwise, directly to course
  
    @State private var selectedFolder: Folder?
  
    var completion: ((String, Course?, Folder?) -> Void)

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                // Drop-down that provides list of available courses to choose from
                Picker("Course", selection: $courseName) {
                    ForEach(courses) { course in
                        Text(course.courseName).tag(course.courseName)
                    }
                }
                Picker("Folder", selection: $selectedFolder) {
                    Text("None").tag(nil as Folder?)
                    ForEach(courseFolders) { folder in
                        Text(folder.folderName).tag(folder as Folder?)
                    }
                }
                Button("Next") {
                    if let selectedCourse = courses.first(where: { $0.courseName == courseName }) {
                        self.course = selectedCourse
                    }
                    completion(title, course, selectedFolder)
                    isPresented = false
                }
                .disabled(courseName.isEmpty)
            }
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                courses = firebase.courses
                if let firstCourse = courses.first {
                    courseName = firstCourse.courseName
                    fetchFolders(for: firstCourse)
                }
            }
            .onChange(of: courseName) { _ in
                if let selectedCourse = courses.first(where: { $0.courseName == courseName }) {
                    fetchFolders(for: selectedCourse)
                }
            }
        }
    }

    private func fetchFolders(for course: Course) {
        firebase.getFoldersById(folderIDs: course.folders) { fetchedFolders in
            self.courseFolders = fetchedFolders
        }
    }
}
