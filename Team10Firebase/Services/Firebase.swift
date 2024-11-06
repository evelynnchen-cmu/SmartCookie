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
  

  
  func getFolders(completion: @escaping ([Folder]) -> Void) {
      db.collection(folderCollection).addSnapshotListener { querySnapshot, error in
          if let error = error {
              print("Error fetching folders: \(error.localizedDescription)")
              completion([]) // Return an empty array in case of an error
              return
          }

          let folders = querySnapshot?.documents.compactMap { document in
              try? document.data(as: Folder.self)
          } ?? []

          print("Total folders fetched: \(folders.count)")
          for folder in folders {
              print("Fetched folder: \(folder)")
          }

          completion(folders) // Pass the fetched folders to the completion handler
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
  
//  func createFolder(
//      folderName: String,
//      course: Course,
//      notes: [String] = [],
//      fileLocation: String = ""
//  ) async throws {
//      // Ensure the course has a valid ID and userID
//      guard let courseID = course.id, !courseID.isEmpty else {
//          print("Error: Missing course ID.")
//          return
//      }
//
//      getFirstUser { user in
//          guard let user = user, let userID = user.id, !userID.isEmpty else {
//              print("Error: Missing user ID.")
//              return
//          }
//
//          let folder = Folder(
//              id: nil,
//              userID: userID,
//              folderName: folderName,
//              courseID: courseID, // Associate this folder with the course
//              notes: notes,
//              fileLocation: fileLocation,
//              recentNoteSummary: nil
//          )
//
//          Task {
//              do {
//                  let _ = try await Firestore.firestore().collection("Folder").addDocument(from: folder)
//                  print("Folder created successfully and linked to course.")
//              } catch {
//                  print("Error creating folder: \(error.localizedDescription)")
//              }
//          }
//      }
//  }
  
  func createFolder(folderName: String, course: Course, notes: [String] = [], fileLocation: String = "") async throws {
      let db = Firestore.firestore()
      let courseID = course.id ?? ""
      let userID = course.userID ?? ""
      
      // Create the folder document
      var ref: DocumentReference? = nil
      ref = db.collection("Folder").addDocument(data: [
          "userID": userID,
          "folderName": folderName,
          "courseID": courseID,
          "notes": notes,
          "fileLocation": fileLocation,
          "recentNoteSummary": NSNull() // Explicitly setting to NSNull for Firestore
      ]) { error in
          if let error = error {
              print("Error adding folder: \(error)")
              return
          }
          
          guard let folderID = ref?.documentID else { return }
          
          // Update the course to include this new folder in its folders array
          db.collection("Course").document(courseID).updateData([
              "folders": FieldValue.arrayUnion([folderID])
          ]) { error in
              if let error = error {
                  print("Error updating course with new folder: \(error)")
              } else {
                  print("Folder successfully added to course!")
              }
          }
      }
  }


  

  
  
  func createNote(
      noteTitle: String,
      noteContent: String,
      course: Course,
      summary: String = "",
      images: [URL] = [],
      fileLocation: String = ""
  ) async throws {
      // Ensure the course has a valid ID and userID
      guard let courseID = course.id, !courseID.isEmpty else {
          print("Error: Missing course ID.")
          return
      }

      getFirstUser { user in
          guard let user = user, let userID = user.id, !userID.isEmpty else {
              print("Error: Missing user ID.")
              return
          }

          let note = Note(
              id: nil,
              userID: userID,
              title: noteTitle,
              summary: summary,
              content: noteContent,
              images: images,
              createdAt: Date(),
              courseID: courseID,
              fileLocation: fileLocation,
              lastAccessed: nil
          )

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
  
  
      func deleteCourse(course: Course) {
          guard let courseID = course.id else {
              print("Course ID is missing.")
              return
          }
          
          let batch = db.batch()
          
          var allNoteIDs: [String] = []
          
          allNoteIDs.append(contentsOf: course.notes)
          
          let folderQuery = db.collection("Folder").whereField("courseID", isEqualTo: courseID)
          
          folderQuery.getDocuments { (querySnapshot, error) in
              if let error = error {
                  print("Error fetching folders: \(error.localizedDescription)")
                  return
              }
              
              guard let folderDocuments = querySnapshot?.documents else {
                  print("No folders found for course.")
                  return
              }
              
              var folderIDsToDelete: [String] = []
              
              for folderDoc in folderDocuments {
                  let folderID = folderDoc.documentID
                  folderIDsToDelete.append(folderID)
                  
                  if let folder = try? folderDoc.data(as: Folder.self) {
                      allNoteIDs.append(contentsOf: folder.notes)
                  }
                  
                  let folderRef = self.db.collection("Folder").document(folderID)
                  batch.deleteDocument(folderRef)
              }
              
              for noteID in allNoteIDs {
                  let noteRef = self.db.collection("Note").document(noteID)
                  batch.deleteDocument(noteRef)
              }
              
              let courseRef = self.db.collection("Course").document(courseID)
              batch.deleteDocument(courseRef)
              
              batch.commit { error in
                  if let error = error {
                      print("Error committing batch delete: \(error.localizedDescription)")
                  } else {
                      print("Successfully deleted course \(courseID) and its related data.")
                  }
                  
                  self.getCourses()
              }
          }
      }


  
  
  





}
