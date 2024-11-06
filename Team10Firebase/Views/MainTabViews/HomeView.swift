

import SwiftUI

struct HomeView: View {
    @StateObject private var firebase = Firebase()
    @State private var errorMessage: String?
    
    @State private var courses: [Course] = []
    @State private var showAddCourseModal = false
    @State private var isLoading = false
    @State private var showDeleteAlert = false
    @State private var courseToDelete: Course?
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        Text("Home")
                            .font(.largeTitle)
                        
                        ForEach(firebase.courses, id: \.id) { course in
                            NavigationLink(destination: CourseView(course: course)) {
                                Text(course.courseName)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.vertical, 2)
                            }
                            .simultaneousGesture(
                                LongPressGesture()
                                    .onEnded { _ in
                                        courseToDelete = course
                                        showDeleteAlert = true
                                    }
                            )
                        }
                    }
                }
                
                Button(action: {
                    showAddCourseModal = true
                }) {
                    Text("Add Course")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .sheet(isPresented: $showAddCourseModal) {
                    // Need onCourseCreated to refresh HomeView after course creation
                    AddCourseModal(onCourseCreated: firebase.getCourses, firebase: firebase)
                }
                .onAppear {
                    firebase.getCourses()
                    firebase.getNotes()
                    firebase.getFolders { _ in }
                    firebase.getMCQuestions()
                    firebase.getNotifications()
                    firebase.getUsers()
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Course"),
                    message: Text("Are you sure you want to delete this course and all its associated data?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let courseToDelete = courseToDelete {
                            firebase.deleteCourse(course: courseToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    HomeView()
}


