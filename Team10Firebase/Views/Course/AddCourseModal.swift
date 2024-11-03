//
//  AddCourseModal.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 10/31/24.
//

//import SwiftUI
//import FirebaseFirestore
//
//struct AddCourseModal: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var courseName: String = ""
//    @State private var showError = false
//    @State private var errorMessage: String = ""
//    
//    // Callback to refresh HomeView after course creation
//    var onCourseCreated: () -> Void
//    
//    @ObservedObject var firebase: Firebase
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Course Information")) {
//                    TextField("Course Name", text: $courseName)
//                }
//                
//                Button(action: {
//                    Task {
//                        do {
//                          try await firebase.createCourse(courseName: courseName)
//                          onCourseCreated()
//                          dismiss()
//                        } catch {
//                            errorMessage = error.localizedDescription
//                            showError = true
//                        }
//                    }
//                }) {
//                    Text("Create Course")
//                }
//                .disabled(courseName.isEmpty)
//            }
//            .navigationTitle("New Course")
//            .navigationBarItems(trailing: Button("Cancel") {
//                dismiss()
//            })
//            .alert("Error", isPresented: $showError) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text(errorMessage)
//            }
//        }
//    }
//}


import SwiftUI
import FirebaseFirestore

struct AddCourseModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var courseName: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    
    // Callback to refresh HomeView after course creation
    var onCourseCreated: () -> Void
    
    @ObservedObject var firebase: Firebase
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Information")) {
                    TextField("Course Name", text: $courseName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 4)
                }
                
                Button("Create Course") {
                    Task {
                        do {
                            // Call to create a new course in Firestore
                            try await firebase.createCourse(courseName: courseName)
                            onCourseCreated()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
                .disabled(courseName.isEmpty)
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
            }
            .navigationTitle("New Course")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

