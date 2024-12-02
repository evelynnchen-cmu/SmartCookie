//
//  EditCourseModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/2/24.
//

import SwiftUI
import FirebaseFirestore


struct EditCourseModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var courseName: String
    let course: Course
    @ObservedObject var firebase: Firebase
    var onCourseUpdated: () -> Void
    
    init(course: Course, firebase: Firebase, onCourseUpdated: @escaping () -> Void) {
        self.course = course
        self.firebase = firebase
        self.onCourseUpdated = onCourseUpdated
        _courseName = State(initialValue: course.courseName)
    }
    
    var body: some View {
        NavigationView {

          NavigationView {
              Form {
                  Section(header: Text("Course Information")) {
                      TextField("Course Name", text: $courseName)
                  }

                Button("Update Course") {
                    guard let courseID = course.id else {
                        print("Error: Missing course ID")
                        return
                    }
                    print("Debug: Updating course name to \(courseName)")
                    firebase.updateCourseName(courseID: courseID, newName: courseName) { error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Debug: Course name successfully updated")
                            onCourseUpdated()
                            dismiss()
                        }
                    }
                }
              }
              .navigationTitle("Edit Course")
              .toolbar {
                  Button("Cancel") {
                      dismiss()
                  }
              }
          }

        }
    }
}
