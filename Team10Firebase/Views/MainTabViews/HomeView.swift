import SwiftUI

struct HomeView: View {
    @StateObject private var firebase = Firebase()
    @State private var errorMessage: String?
    
    @State private var courses: [Course] = []
    @State private var showAddCourseModal = false
    @State private var isLoading = false
    @State private var showDeleteAlert = false
    @State private var courseToDelete: Course?
    @State private var userName: String = "User"
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Spacer().frame(height: 40)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Welcome back,")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(userName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Classes")
                                .font(.title3)
                                .fontWeight(.medium)
                           
                            Button(action: {
                                showAddCourseModal = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 25, height: 25)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(firebase.courses, id: \.id) { course in
                                NavigationLink(destination: CourseView(course: course)) {
                                    Text(course.courseName)
                                        .font(.headline)
                                        .frame(height: 100)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
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
                        .padding(.horizontal)
                    }
                }
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
                    firebase.getFirstUser { user in
                        if let user = user {
                            userName = user.name
                        } else {
                            errorMessage = "Failed to fetch user."
                        }
                    }
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
