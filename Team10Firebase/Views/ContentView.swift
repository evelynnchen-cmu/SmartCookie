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
            List(firebase.courses) { course in
                VStack(alignment: .leading) {
                    Text(course.courseName)
                        .font(.headline)
                    Text("User ID: \(course.userID)")
                        .font(.subheadline)
                }
            }
            .navigationBarTitle("Courses")
            .onAppear {
                firebase.fetchCourses()
            }
        }
    }
}

#Preview {
    ContentView()
}
