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
    @State private var streakLength: Int = 0
    @State private var hasCompletedStreakToday: Bool = false
    @StateObject private var editState = EditCourseState()

    @Binding var navigateToCourse: Course?
    @Binding var navigateToNote: Note?
    
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
                              
                              StreakIndicator(count: streakLength, isActiveToday: hasCompletedStreakToday)
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
                              ZStack(alignment: .topTrailing) {
                                  NavigationLink(destination: CourseView(course: course, firebase: firebase)) {
                                      Text(course.courseName)
                                          .font(.headline)
                                          .frame(height: 100)
                                          .frame(maxWidth: .infinity)
                                          .background(Color.blue.opacity(0.2))
                                          .cornerRadius(12)
                                          .foregroundColor(.primary)
                                  }
                                  
                                  HStack {
                                      Button(action: {
                                          print("Debug: Before setting courseToEdit - Button pressed")
                                          editState.courseToEdit = course
                                          print("Debug: After setting courseToEdit: \(editState.courseToEdit?.courseName ?? "nil")")
                                          print("Debug: Course details - ID: \(course.id ?? "nil"), Name: \(course.courseName)")
                                          editState.showEditModal = true
                                      }) {
                                          Image(systemName: "pencil.circle.fill")
                                              .font(.title3)
                                              .foregroundColor(.blue)
                                              .background(Color.white.opacity(0.8))
                                              .clipShape(Circle())
                                      }
                                      .padding(8)
                                      .zIndex(1)
                                  }
                              }
                              .contentShape(Rectangle())
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
                    AddCourseModal(onCourseCreated: firebase.getCourses, firebase: firebase)
                }
                  .sheet(isPresented: $editState.showEditModal) {
                      if let courseToEdit = editState.courseToEdit {
                          EditCourseModal(
                              course: courseToEdit,
                              firebase: firebase,
                              onCourseUpdated: {
                                  firebase.getCourses()
                                  editState.showEditModal = false
                              }
                          )
                      }
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
                    getStreakInfo()
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
            .onAppear {
                if let course = navigateToCourse, let note = navigateToNote {
                    navigateToCourse = nil
                    navigateToNote = nil
                }
            }
        }
        
    }
  
    private func getStreakInfo() {
        firebase.getFirstUser { user in
            if let user = user {
                userName = user.name
                streakLength = user.streak.currentStreakLength
                
                if let lastQuizDate = user.streak.lastQuizCompletedAt {
                    hasCompletedStreakToday = Calendar.current.isDate(lastQuizDate, inSameDayAs: Date())
                } else {
                    hasCompletedStreakToday = false
                }
            } else {
                errorMessage = "Failed to fetch user."
            }
        }
    }
}

struct StreakIndicator: View {
    let count: Int
    let isActiveToday: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isActiveToday ? .orange : .gray)
            
            Image(systemName: isActiveToday ? "flame.fill" : "flame")
                .font(.title2)
                .foregroundColor(isActiveToday ? .orange : .gray)

        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActiveToday ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
}

