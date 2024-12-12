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
    var folder: Folder? // Optional, if provided, note is added to this folder; otherwise, directly to course
  
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
              courses = firebase.courses
              if let firstCourse = courses.first {
                  courseName = firstCourse.courseName
              }
            }
        }
    }
}
