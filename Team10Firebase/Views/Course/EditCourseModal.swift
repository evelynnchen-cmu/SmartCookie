//
//  EditCourseModal.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 12/2/24.
//

import SwiftUI
import FirebaseFirestore




class EditCourseState: ObservableObject {
    @Published var courseToEdit: Course?
    @Published var showEditModal: Bool = false
}



struct EditCourseModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String
    let course: Course
    @ObservedObject var firebase: Firebase
    var onCourseUpdated: () -> Void
    
    init(course: Course, firebase: Firebase, onCourseUpdated: @escaping () -> Void) {
        print("Debug: EditCourseModal init with course: \(course.courseName)")
        self.course = course
        self.firebase = firebase
        self.onCourseUpdated = onCourseUpdated
        self._newName = State(initialValue: course.courseName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Name")) {
                    TextField("Course Name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Button(action: {
                        guard let courseID = course.id else { return }
                        print("Attempting to update course name to: \(newName)")
                        firebase.updateCourseName(courseID: courseID, newName: newName) { error in
                            if let error = error {
                                print("Error updating course: \(error.localizedDescription)")
                            } else {
                                print("Course name updated successfully")
                                onCourseUpdated()
                                dismiss()
                            }
                        }
                    }) {
                        Text("Update Course")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(newName.isEmpty || newName == course.courseName ? Color.gray : darkBrown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Edit Course")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
        .interactiveDismissDisabled()  // Prevents accidental dismissal
        .onAppear {
            print("Modal appeared with name: \(newName)")
        }
    }
}
