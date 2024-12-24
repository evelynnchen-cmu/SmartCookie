//
//  HomeView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var firebase = Firebase()
    @State private var errorMessage: String?
    
    @State private var courses: [Course] = []
    @State private var showAddCourseModal = false
    @State private var isLoading = false
    @State private var showDeleteAlert = false
    @State private var courseToDelete: Course?
    @State private var userName: String = "Evelynn"
    @State private var streakLength: Int = 0
    @State private var hasCompletedStreakToday: Bool = false
    @StateObject private var editState = EditCourseState()

    @Binding var navigateToCourse: Course?
    @Binding var navigateToNote: Note?
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
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

                         Spacer().frame(width: 50)

                            Image("cookieIcon")
                               .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(height: 120)
                        }
                        .padding(.horizontal)
                      
                      VStack(alignment: .leading) {
                            Text("Dive back in!🥛")
                            .font(.title3)
                            .fontWeight(.medium)
                              .padding(.leading, 20)
                          
                          ScrollView(.horizontal, showsIndicators: false) {
                              HStack(spacing: 12) {
                                  ForEach(firebase.getMostRecentlyUpdatedNotes(), id: \.id) { note in
                                      let course = firebase.courses.first { $0.id == note.courseID }
                                      
                                      NavigationLink(destination: NoteView(firebase: firebase, note: note, 
                                      course: course ?? Course(userID: "", courseName: "", folders: [], notes: [], fileLocation: ""))) {
                                          RecentNoteCard(note: note, course: course)
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
                      
                      CourseGrid(
                          courses: firebase.courses,
                          onEdit: { course in
                              editState.courseToEdit = course
                              editState.showEditModal = true
                          },
                          onDelete: { course in
                              courseToDelete = course
                              showDeleteAlert = true
                          },
                          onSelect: { course in
                              navigationPath.append(course)
                          }
                      )
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
                          firebase.deleteCourse(courseID: courseToDelete.id ?? "") {_ in
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
                navigationPath.removeLast(navigationPath.count)
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

struct CourseGrid: View {
    let courses: [Course]
    let colors: [Color] = [darkBrown, lightBrown, mediumBlue, darkBlue, lightBlue]
    let onEdit: (Course) -> Void
    let onDelete: (Course) -> Void
    let onSelect: (Course) -> Void
    
    func getColorForIndex(_ index: Int) -> Color {
        colors[index % colors.count]
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Array(courses.enumerated()), id: \.element.id) { index, course in
                CourseCard(
                    course: course,
                    backgroundColor: getColorForIndex(index),
                    onEdit: { onEdit(course) },
                    onSelect: { onSelect(course) }
                )
                .contextMenu {
                    Button(action: {
                        onEdit(course)
                    }) {
                        Label("Edit Course", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        onDelete(course)
                    }) {
                        Label("Delete Course", systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CourseCard: View {
    let course: Course
    let backgroundColor: Color
    let onEdit: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: 80)
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
                
                HStack {
                    Text(course.courseName)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
                .frame(height: 42)
                .background(Color.white)
            }
            .frame(height: 122)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}

struct RecentNoteCard: View {
    let note: Note
    let course: Course?
    
    var body: some View {
      VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if let courseName = course?.courseName {
                Text(courseName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Text(note.summary)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.gray)
        }
      .padding(.horizontal, 8)
      .padding(.vertical, 12)
        .frame(width: 150, height: 100, alignment: .topLeading)
        .background(lightBlue)
        .cornerRadius(8)
    }
}
