//
//  ChatHeaderView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/11/24.
//

import Foundation
import SwiftUI

struct ChatHeaderView: View {
    @Binding var selectedScope: String
    @Binding var isMessageSelectionViewPresented: Bool
    @Binding var isChatViewPresented: Bool?
    @ObservedObject var firebase: Firebase

    @State private var localCourses: [Course] = []

    var body: some View {
        HStack {
            // Save messages button
            Button(action: {
                isMessageSelectionViewPresented = true
            }) {
                Image(systemName: "square.and.arrow.down.on.square")
                    .foregroundColor(.black)
            }

            Spacer()

            // Dropdown menu for course selection
            Menu {
                Button(action: {
                    print("Selected General explicitly")
                    selectedScope = "General"
                }) {
                    Text("General")
                }

                let _ = print("Rendering menu with firebase: \(firebase.courses.count) courses, local: \(localCourses.count) courses")
                
                // Use either firebase courses or local cached courses
                let coursesToDisplay = !firebase.courses.isEmpty ? firebase.courses : localCourses

                if coursesToDisplay.isEmpty {
                    Button(action: {}) {
                        Text("No courses available").foregroundColor(.gray)
                    }
                } else {
                    ForEach(coursesToDisplay, id: \.id) { course in
                        Button(action: {
                            print("Selected course: \(course.courseName ?? "unknown") with ID: \(course.id ?? "unknown")")
                            if let courseId = course.id {
                                selectedScope = courseId
                            }
                        }) {
                            Text(course.courseName ?? "Unknown")
                        }
                    }
                }
            } label: {
                HStack {
                    let displayName = if selectedScope == "General" {
                        "General"
                    } else {
                        localCourses.first { $0.id == selectedScope }?.courseName ?? selectedScope
                    }
                    Text(displayName)
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .foregroundColor(.black)
            }
            .id(firebase.courses.count)

            Spacer()

            // Close chat button
            if let isPresented = isChatViewPresented {
                Button(action: {
                    isChatViewPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .onAppear {
            print("ChatHeaderView appeared with scope: \(selectedScope)")
            print("Available courses: \(firebase.courses.map { "\($0.id ?? "unknown"): \($0.courseName ?? "unknown")" })")

            loadCoursesIfNeeded()
        }
        .onChange(of: firebase.courses) { newCourses in
            print("Firebase courses changed to \(newCourses.count) courses")
            if !newCourses.isEmpty {
                localCourses = newCourses
            }
        }
    }

    private func loadCoursesIfNeeded() {
        print("Loading check - Firebase: \(firebase.courses.count) courses, Local: \(localCourses.count) courses")
        if firebase.courses.isEmpty && localCourses.isEmpty {
            print("Loading courses as both caches are empty")
            firebase.getCourses()
        } else {
            print("Using cached courses")
            // Only refresh if we don't have local courses
            if localCourses.isEmpty {
                firebase.getCourses()
            }
        }
    }
}
