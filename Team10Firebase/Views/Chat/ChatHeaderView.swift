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

    @FocusState private var isTextFieldFocused: Bool

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

                let _ = print("Rendering menu with \(firebase.courses.count) courses")

                if firebase.courses.isEmpty {
                    Button(action: {}) {
                        Text("No courses available").foregroundColor(.gray)
                    }
                } else {
                    ForEach(firebase.courses, id: \.id) { course in
                        Button(action: {
                            print("Selected course: \(course.courseName ?? "unknown") with ID: \(course.id ?? "unknown")")
                            if let courseId = course.id {
                                selectedScope = courseId
                            }
                        }) {
                            Text(course.courseName ?? "Unknown")
                                .onAppear {
                                    print("Course option appeared: \(course.courseName ?? "unknown")")
                                }
                        }
                    }
                }
            } label: {
                HStack {
                    let displayName = if selectedScope == "General" {
                        "General"
                    } else {
                        firebase.courses.first { $0.id == selectedScope }?.courseName ?? selectedScope
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
            .onChange(of: isTextFieldFocused) { focused in
                print("TextField focus changed to: \(focused)")
                if focused {
                    // Reload courses when keyboard appears
                    loadCoursesIfNeeded()
                }
            }
            .onAppear {
                print("Menu appeared with scope: \(selectedScope)")
                print("Menu opened with \(firebase.courses.count) courses")
                loadCoursesIfNeeded()
            }

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
        .onDisappear {
            print("ChatHeaderView disappeared with \(firebase.courses.count) courses")
        }
    }

    private func loadCoursesIfNeeded() {
        print("Checking courses need loading. Current count: \(firebase.courses.count)")
        if firebase.courses.isEmpty {
            print("Loading courses as they were empty")
            firebase.getCourses()
        } else {
            print("Courses already loaded: \(firebase.courses.count)")
            // Add a refresh anyway to ensure we have latest data
            firebase.getCourses()
        }
    }
}
