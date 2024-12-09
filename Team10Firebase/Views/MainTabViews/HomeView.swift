import SwiftUI


struct RecentNoteCard: View {
    let note: Note
    let course: Course?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {  // Reduced spacing
            Text(note.title)
                .font(.subheadline)  // Smaller font
                .fontWeight(.medium)
                .lineLimit(1)
            
            if let courseName = course?.courseName {
                Text(courseName)
                    .font(.caption)  // Smaller font
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Text(note.summary)
                .font(.caption)  // Smaller font
                .lineLimit(2)
                .foregroundColor(.gray)
        }
        .padding(8)  // Reduced padding
        .frame(height: 100)  // Reduced height
        .background(lightBlue)
        .cornerRadius(8)  // Slightly reduced corner radius
    }
}

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
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        // NavigationView {
        NavigationStack(path: $navigationPath) {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Spacer().frame(height: 40)
//                        Spacer().frame(height: 20)
//                      Spacer().frame(height: 2)

                        HStack(alignment: .top) {
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 3)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Welcome back,")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(userName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(lightBrown)
                              
                              StreakIndicator(count: streakLength, isActiveToday: hasCompletedStreakToday)
                            }

                        //   Spacer().frame(width: 40)
                         Spacer().frame(width: 50)

//                          VStack(alignment: .center) {
                            Image("cookieIcon")
                               .resizable()
                              .aspectRatio(contentMode: .fit)
//                               .frame(width: 120, height: 120)
                              .frame(height: 120)
//                          }
                          
                            // NavigationLink(destination: SettingsView()) {
                            //     Image(systemName: "gearshape")
                            //         .font(.title2)
                            //         .foregroundColor(.black)
                            // }
                        }
                        .padding(.horizontal)
                      
                      VStack(alignment: .leading) {
                        //   Text("Recently Updated Notes")
                            Text("Dive back in!🥛")
                            //   .font(.headline)
                            .font(.title3)
                            .fontWeight(.medium)
                        //   .foregroundColor(.blue)
                              .padding(.leading, 20)
                          
                          ScrollView(.horizontal, showsIndicators: false) {
                              HStack(spacing: 12) {  // Reduced spacing between cards
                                  ForEach(firebase.getMostRecentlyUpdatedNotes(), id: \.id) { note in
                                      let course = firebase.courses.first { $0.id == note.courseID }
                                      
                                      NavigationLink(destination: NoteView(firebase: firebase, note: note, course: course ?? Course(userID: "", courseName: "", folders: [], notes: [], fileLocation: ""))) {
                                          RecentNoteCard(note: note, course: course)
                                              .frame(width: 150)  // Reduced width for each card
                                      }
                                      .buttonStyle(PlainButtonStyle())
                                  }
                              }
                              .padding(.horizontal)
                          }
                      }
                      .padding(.vertical, 8)

                        
                        HStack {
                            Text("Classes")
                                .font(.title3)
                                .fontWeight(.medium)
                           
                            Button(action: {
                                showAddCourseModal = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .foregroundColor(darkBrown)
                                    .frame(width: 25, height: 25)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(darkBrown, lineWidth: 2)
                                    )
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
                                Button(action: {
                                    navigationPath.append(course)
                                }) {
                                    Text(course.courseName)
                                        .font(.headline)
                                        .frame(height: 100)
                                        .frame(maxWidth: .infinity)
                                        .background(lightBlue)
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }
                                  
                                  HStack {
                                      Button(action: {
                                          editState.courseToEdit = course
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
                            // firebase.deleteCourse(course: courseToDelete)
                          firebase.deleteCourse(courseID: courseToDelete.id ?? "") {_ in 
                                // firebase.getCourses()
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                if let course = navigateToCourse, let note = navigateToNote {
                  navigateToCourse = nil
                  navigateToNote = nil
                  navigationPath.append(course)
                  navigationPath.append(note)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetHomeView)) { _ in
                // Reset the HomeView to its root
                navigationPath = NavigationPath()
            }
            .navigationDestination(for: Course.self) { course in
                CourseView(course: course, firebase: firebase, navigationPath: $navigationPath)
            }
        }
        .navigationBarHidden(true)
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
            Text("\(count) day streak")
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

