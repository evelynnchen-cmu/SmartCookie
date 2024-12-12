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
    var hasUnsavedMessages: Bool
    @Binding var showExitConfirmation: Bool

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
                    if hasUnsavedMessages {
                        showExitConfirmation = true
                    } else {
                        isChatViewPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .onAppear {
            loadCoursesIfNeeded()
        }
        .onChange(of: firebase.courses) { newCourses in
            if !newCourses.isEmpty {
                localCourses = newCourses
            }
        }
    }

    private func loadCoursesIfNeeded() {
        if firebase.courses.isEmpty && localCourses.isEmpty {
            firebase.getCourses()
        } else {
            // Only refresh if we don't have local courses
            if localCourses.isEmpty {
                firebase.getCourses()
            }
        }
    }
}
