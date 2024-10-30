//
//  ContentView.swift
//  Team10Firebase
//
//  Created by Vicky Chen on 10/21/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebase = Firebase()
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Courses:")
                        .font(.largeTitle)
                        .padding(.leading)

                    ForEach(firebase.courses) { course in
                        CourseViewTest(course: course)
                    }

                    Text("Notes:")
                        .font(.largeTitle)
                        .padding(.leading)

                    ForEach(firebase.notes) { note in
                        NoteViewTest(note: note)
                    }

                    Text("Folders:")
                        .font(.largeTitle)
                        .padding(.leading)

                    ForEach(firebase.folders) { folder in
                        FolderViewTest(folder: folder)
                    }
                    Text("MCQuestions:")
                        .font(.largeTitle)
                        .padding(.leading)
                    ForEach(firebase.mcQuestions) { mcQuestion in
                        MCQuestionViewTest(mcQuestion: mcQuestion)
                    }
                    Text("Notifications:")
                        .font(.largeTitle)
                        .padding(.leading)
                    ForEach(firebase.notifications) { notification in
                        NotificationViewTest(notification: notification)
                    }
                    Text("Users:")
                        .font(.largeTitle)
                        .padding(.leading)
                    ForEach(firebase.users) { user in
                        UserViewTest(user: user)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Team10Firebase")
            .onAppear {
              firebase.getCourses()
              firebase.getNotes()
              firebase.getFolders()
              firebase.getMCQuestions()
              firebase.getNotifications()
              firebase.getUsers()
            }
        }
    }
}

struct CourseViewTest: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading) {
          Text("Course ID: \(course.id)")
              .font(.body)
          Text("userID: \(course.userID)")
              .font(.body)
            Text(course.courseName)
                .font(.body)
            Text("folders: \(course.folders)")
                .font(.body)
            Text("notes: \(course.notes)")
                .font(.body)
          Text("fileLocation: \(course.fileLocation)")
              .font(.body)
        }
        .padding(.leading)
    }
}

struct NoteViewTest: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading) {
          Text("id: \(note.id)")
              .font(.body)
          Text("title: \(note.title)")
              .font(.body)
          Text("summary: \(note.summary)")
              .font(.body)
          Text("content: \(note.content)")
              .font(.body)
          Text("images: \(note.images)")
              .font(.body)
          Text("createdAt: \(note.createdAt)")
              .font(.body)
          Text("courseID: \(note.courseID)")
              .font(.body)
          Text("fileLocation: \(note.fileLocation)")
              .font(.body)
            if let lastAccessed = note.lastAccessed {
                Text("Last Accessed: \(lastAccessed)")
                    .font(.body)
            }
        }
        .padding(.leading)
    }
}

struct FolderViewTest: View {
    let folder: Folder

    var body: some View {
        VStack(alignment: .leading) {
          Text("id: \(folder.id)")
              .font(.body)
          Text("userID: \(folder.userID)")
              .font(.body)
          Text("courseID: \(folder.courseID)")
              .font(.body)
          Text("notes: \(folder.notes)")
              .font(.body)
          Text("fileLocation: \(folder.fileLocation)")
              .font(.body)
          Text("recentNoteSummary: \(folder.recentNoteSummary)")
              .font(.body)
        }
        .padding(.leading)
    }
}

struct MCQuestionViewTest: View {
    let mcQuestion: MCQuestion
    var body: some View {
        VStack(alignment: .leading) {
            Text("id: \(mcQuestion.id)")
                .font(.body)
            Text("question: \(mcQuestion.question)")
                .font(.body)
            Text("potentialAnswers: \(mcQuestion.potentialAnswers.joined(separator: ", "))")
                .font(.body)
            Text("correctAnswer: \(mcQuestion.correctAnswer)")
                .font(.body)
        }
        .padding(.leading)
    }
}

struct NotificationViewTest: View {
    let notification: Notification
    var body: some View {
        VStack(alignment: .leading) {
            Text("id: \(notification.id ?? "N/A")")
                .font(.body)
            Text("type: \(notification.type)")
                .font(.body)
            Text("message: \(notification.message)")
                .font(.body)
            if let quizID = notification.quizID {
                Text("quizID: \(quizID)")
                    .font(.body)
            }
            Text("scheduledAt: \(notification.scheduledAt)")
                .font(.body)
            if let userID = notification.userID {
                Text("userID: \(userID)")
                    .font(.body)
            }
        }
        .padding(.leading)
    }
}

struct UserViewTest: View {
    let user: User
    var body: some View {
        VStack(alignment: .leading) {
            Text("id: \(user.id ?? "N/A")")
                .font(.body)
            Text("name: \(user.name)")
                .font(.body)
            Text("notifications: \(user.notifications.joined(separator: ", "))")
                .font(.body)
            Text("streak: \(user.streak.currentStreakLength)")
                .font(.body)
            Text("courses: \(user.courses.joined(separator: ", "))")
                .font(.body)
            Text("notificationsEnabled: \(user.settings.notificationsEnabled ? "Enabled" : "Disabled")")
                .font(.body)
            Text("notificationFrequency: \(user.settings.notificationFrequency)")
                .font(.body)
            Text("notesOnlyQuizScope: \(user.settings.notesOnlyQuizScope ? "Enabled" : "Disabled")")
                .font(.body)
            Text("notesOnlyChatScope: \(user.settings.notesOnlyChatScope ? "Enabled" : "Disabled")")
                .font(.body)
            Text("quizzes: \(user.quizzes.map { $0.quizID ?? "N/A" }.joined(separator: ", "))")
                .font(.body)
        }
        .padding(.leading)
    }
}

#Preview {
    ContentView()
}
