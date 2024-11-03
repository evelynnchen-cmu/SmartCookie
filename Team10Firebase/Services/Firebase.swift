//
//  Firebase.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/29/24.
//

import Foundation
import FirebaseFirestore

class Firebase: ObservableObject {
  private let db = Firestore.firestore()
  
  @Published var courses: [Course] = []
  @Published var notes: [Note] = []
  @Published var folders: [Folder] = []
  @Published var mcQuestions: [MCQuestion] = []
  @Published var notifications: [Notification] = []
  @Published var users: [User] = []
  
  private let courseCollection = "Course"
  private let noteCollection = "Note"
  private let folderCollection = "Folder"
  private let mcQuestionCollection = "MCQuestion"
  private let notificationCollection = "Notification"
  private let userCollection = "User"
  
  // get methods
  func getCourses() {
    db.collection(courseCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching courses: \(error.localizedDescription)")
        return
      }
      
      self.courses = querySnapshot?.documents.compactMap { document in
        try? document.data(as: Course.self)
      } ?? []
      
      print("Total courses fetched: \(self.courses.count)")
      for course in self.courses {
        print("Fetched course: \(course)")
      }
    }
  }
  
  func getNotes() {
    db.collection(noteCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching notes: \(error.localizedDescription)")
        return
      }
      
      self.notes = querySnapshot?.documents.compactMap { document in
        try? document.data(as: Note.self)
      } ?? []
      
      print("Total notes fetched: \(self.notes.count)")
      for note in self.notes {
        print("Fetched note: \(note)")
      }
    }
  }
  
  func getFolders() {
    db.collection(folderCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching folders: \(error.localizedDescription)")
        return
      }
      
      self.folders = querySnapshot?.documents.compactMap { document in
        try? document.data(as: Folder.self)
      } ?? []
      
      print("Total folders fetched: \(self.folders.count)")
      for folder in self.folders {
        print("Fetched folder: \(folder)")
      }
    }
  }
  
  func getMCQuestions() {
    db.collection(mcQuestionCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching MCQuestions: \(error.localizedDescription)")
        return
      }
      
      self.mcQuestions = querySnapshot?.documents.compactMap { document in
        try? document.data(as: MCQuestion.self)
      } ?? []
      
      print("Total MCQuestions fetched: \(self.mcQuestions.count)")
      for mcQuestion in self.mcQuestions {
        print("Fetched MCQuestion: \(mcQuestion)")
      }
    }
  }
  
  func getNotifications() {
    db.collection(notificationCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching notifications: \(error.localizedDescription)")
        return
      }
      
      self.notifications = querySnapshot?.documents.compactMap { document in
        try? document.data(as: Notification.self)
      } ?? []
      
      print("Total notifications fetched: \(self.notifications.count)")
      for notification in self.notifications {
        print("Fetched notification: \(notification)")
      }
    }
  }
  
  func getUsers() {
    db.collection(userCollection).addSnapshotListener { querySnapshot, error in
      if let error = error {
        print("Error fetching users: \(error.localizedDescription)")
        return
      }
      
      self.users = querySnapshot?.documents.compactMap { document in
        try? document.data(as: User.self)
      } ?? []
      
      print("Total users fetched: \(self.users.count)")
      for user in self.users {
        print("Fetched user: \(user)")
      }
    }
  }

  func getFirstUser(completion: @escaping (User?) -> Void) {
      db.collection(userCollection).limit(to: 1).getDocuments { querySnapshot, error in
          if let error = error {
              print("Error fetching first user: \(error.localizedDescription)")
              completion(nil)
              return
          }
          
          let user = querySnapshot?.documents.compactMap { document in
              try? document.data(as: User.self)
          }.first
          
          completion(user)
      }
  }
  
  // post methods
  func createCourse(courseName: String) async throws {
      getFirstUser { user in
          guard let user = user else {
              print("No user found")
              return
          }
          
          let course = Course(
              id: nil, // Firestore will generate the ID
              userID: user.id!,
              courseName: courseName,
              folders: [],
              notes: [],
              fileLocation: "/\(courseName)/"
          )
          
          do {
              let _ = try self.db.collection("Course").addDocument(from: course)
          } catch {
              print("Error creating course: \(error.localizedDescription)")
          }
      }
  }
  
//  func createNote(noteTitle: String, noteContent: String, courseID: String, summary: String = "", images: [URL] = [], fileLocation: String = "") async throws {
//      let note = Note(
//          id: nil, // Firestore will generate the ID
//          userID: "userID_placeholder", // Adjust this as needed
//          title: noteTitle,
//          summary: summary,
//          content: noteContent,
//          images: images,
//          createdAt: Date(),
//          courseID: courseID,
//          fileLocation: fileLocation,
//          lastAccessed: nil
//      )
//      
//      do {
//          let _ = try db.collection(noteCollection).addDocument(from: note)
//      } catch {
//          throw error
//      }
//  }
  
  
  func createNote(
      noteTitle: String,
      noteContent: String,
      course: Course, // Pass the course object as a parameter
      summary: String = "",
      images: [URL] = [],
      fileLocation: String = ""
  ) async throws {
      // Ensure the course has a valid ID and userID
      guard let courseID = course.id, !courseID.isEmpty else {
          print("Error: Missing course ID.")
          return
      }

      // Get the first user (assuming you need this to associate the note with a user)
      getFirstUser { user in
          guard let user = user, let userID = user.id, !userID.isEmpty else {
              print("Error: Missing user ID.")
              return
          }

          // Create the note object
          let note = Note(
              id: nil, // Firestore will generate the ID
              userID: userID, // Associate with the user who created the course
              title: noteTitle,
              summary: summary,
              content: noteContent,
              images: images,
              createdAt: Date(),
              courseID: courseID, // Associate with the current course
              fileLocation: fileLocation,
              lastAccessed: nil
          )

          // Add the note to Firestore
          Task {
              do {
                  let _ = try await self.db.collection("Note").addDocument(from: note)
                  print("Note created successfully.")
              } catch {
                  print("Error creating note: \(error.localizedDescription)")
              }
          }
      }
  }


  
  
  





}
