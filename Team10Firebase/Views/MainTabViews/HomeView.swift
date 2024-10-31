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
//  Note: Book/Library class example used @EnvironmentObject var library: Library for model where Library was a ViewModel
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
            }
          }
        }
//        TODO: may change so we aren't loading all the data at once
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
}

#Preview {
    HomeView()
}
