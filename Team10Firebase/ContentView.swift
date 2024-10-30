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
                        CourseView(course: course)
                    }

                    Text("Notes:")
                        .font(.largeTitle)
                        .padding(.leading)

                    ForEach(firebase.notes) { note in
                        NoteView(note: note)
                    }

                    Text("Folders:")
                        .font(.largeTitle)
                        .padding(.leading)

                    ForEach(firebase.folders) { folder in
                        FolderView(folder: folder)
                    }
                      Text("MCQuestions:")
                        .font(.largeTitle)
                        .padding(.leading)
                    ForEach(firebase.mcQuestions) { mcQuestion in
                        MCQuestionView(mcQuestion: mcQuestion)
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
            }
        }
    }
}

struct CourseView: View {
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

struct NoteView: View {
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

struct FolderView: View {
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

struct MCQuestionView: View {
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

#Preview {
    ContentView()
}
