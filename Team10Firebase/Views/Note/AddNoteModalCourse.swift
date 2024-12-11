import SwiftUI
import FirebaseFirestore

struct AddNoteModalCourse: View {
    // @Environment(\.dismiss) private var dismiss
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
    @State var folder: Folder?
  
    var completion: ((String, Course?) -> Void)

    var body: some View {
        NavigationView {
            Form {
                  TextField("Title", text: $title)
                  // Drop-down that provides list of available courses to choose form
                  Picker("Course", selection: $courseName) {
                      ForEach(courses) { course in
                        Text(course.courseName).tag(course.courseName)
                    }
                  }
                  Picker("Folder", selection: $folder) {
                      ForEach(courseFolders) { folder in
                        Text(folder.folderName).tag(folder.folderName)
                    }
                  }
              Button("Next") {
                  if let selectedCourse = courses.first(where: { $0.courseName == courseName }) {
                      self.course = selectedCourse
                  }
                completion(title, course)
                  isPresented = false
              }
              .disabled(courseName.isEmpty)
            }
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Cancel") {
                // dismiss()
                isPresented = false
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
//              firebase.getCourses()
              courses = firebase.courses
              if let firstCourse = courses.first {
                  courseName = firstCourse.courseName
                //   get the folders in FB for a course
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
