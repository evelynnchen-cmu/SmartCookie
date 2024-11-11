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
        // print("Fetched course: \(course)")
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
        // print("Fetched note: \(note)")
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
            //   print("Fetched folder: \(folder)")
          }

          completion(folders)
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
        // print("Fetched MCQuestion: \(mcQuestion)")
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
        // print("Fetched notification: \(notification)")
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
        // print("Fetched user: \(user)")
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
              id: nil,
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
  

  
//  func createFolder(folderName: String, course: Course, notes: [String] = [], fileLocation: String = "") async throws {
//      let db = Firestore.firestore()
//      let courseID = course.id ?? ""
//      let userID = course.userID ?? ""
//      
//      var ref: DocumentReference? = nil
//      ref = db.collection("Folder").addDocument(data: [
//          "userID": userID,
//          "folderName": folderName,
//          "courseID": courseID,
//          "notes": notes,
//          "fileLocation": fileLocation,
//          "recentNoteSummary": NSNull()
//      ]) { error in
//          if let error = error {
//              print("Error adding folder: \(error)")
//              return
//          }
//          
//          guard let folderID = ref?.documentID else { return }
//          
//          db.collection("Course").document(courseID).updateData([
//              "folders": FieldValue.arrayUnion([folderID])
//          ]) { error in
//              if let error = error {
//                  print("Error updating course with new folder: \(error)")
//              } else {
//                  print("Folder successfully added to course!")
//              }
//          }
//      }
//  }
  
  
  
  func createFolder(folderName: String, course: Course, notes: [String] = [], fileLocation: String = "") async throws {
      let db = Firestore.firestore()
      let courseID = course.id ?? ""
      let userID = course.userID ?? ""
      
      var ref: DocumentReference? = nil
      ref = db.collection("Folder").addDocument(data: [
          "userID": userID,
          "folderName": folderName,
          "courseID": courseID,
          "notes": notes,
          "fileLocation": fileLocation,
          "recentNoteSummary": NSNull()
      ]) { error in
          if let error = error {
              print("Error adding folder: \(error)")
              return
          }
          
          guard let folderID = ref?.documentID else { return }
          
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


  
  
//      func createNote(
//          title: String,
//          summary: String,
//          content: String,
//          images: [String] = [],
//          folder: Folder,
//          course: Course,
//          completion: @escaping (Error?) -> Void
//      ) {
//          guard let courseID = course.id, let userID = folder.userID else {
//              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid course or user ID"]))
//              return
//          }
//          
//          let note = Note(
//              id: nil,
//              userID: userID,
//              title: title,
//              summary: summary,
//              content: content,
//              images: images,
//              createdAt: Date(),
//              courseID: courseID,
//              fileLocation: "\(courseID)/\(folder.id ?? "")",
//              lastAccessed: nil
//          )
//          
//          do {
//              let ref = try db.collection(noteCollection).addDocument(from: note)
//              db.collection(folderCollection).document(folder.id ?? "").updateData([
//                  "notes": FieldValue.arrayUnion([ref.documentID])
//              ]) { error in
//                  completion(error)
//              }
//          } catch {
//              print("Error creating note: \(error)")
//              completion(error)
//          }
//      }
  
  
  func createNote(
      title: String,
      summary: String,
      content: String,
      images: [String] = [],
      course: Course,
      folder: Folder? = nil,
      completion: @escaping (Error?) -> Void
  ) {
      guard let courseID = course.id else {
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid course ID"]))
          return
      }
      
      let userID = folder?.userID ?? course.userID // Use userID from folder if available, else course userID
      let note = Note(
          id: nil,
          userID: userID,
          title: title,
          summary: summary,
          content: content,
          images: images,
          createdAt: Date(),
          courseID: courseID,
          fileLocation: "\(courseID)/\(folder?.id ?? "")",
          lastAccessed: nil
      )
      
      do {
          let ref = try db.collection(noteCollection).addDocument(from: note)
          
          if let folder = folder {
              // Add note ID to the specified folder
              db.collection(folderCollection).document(folder.id ?? "").updateData([
                  "notes": FieldValue.arrayUnion([ref.documentID])
              ]) { error in
                  completion(error)
              }
          } else {
              // Add note ID directly to the course
              db.collection(courseCollection).document(courseID).updateData([
                  "notes": FieldValue.arrayUnion([ref.documentID])
              ]) { error in
                  completion(error)
              }
          }
      } catch {
          print("Error creating note: \(error)")
          completion(error)
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
  
  
  
      func deleteFolder(folder: Folder, courseID: String, completion: @escaping (Error?) -> Void) {
          guard let folderID = folder.id else {
              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Folder ID is missing."]))
              return
          }
          
          let batch = db.batch()
          
          folder.notes.forEach { noteID in
              let noteRef = db.collection(noteCollection).document(noteID)
              batch.deleteDocument(noteRef)
          }
          
          let courseRef = db.collection(courseCollection).document(courseID)
          batch.updateData(["folders": FieldValue.arrayRemove([folderID])], forDocument: courseRef)
          
          let folderRef = db.collection(folderCollection).document(folderID)
          batch.deleteDocument(folderRef)
          
          batch.commit { error in
              if let error = error {
                  print("Error deleting folder: \(error.localizedDescription)")
              } else {
                  print("Successfully deleted folder \(folderID) and its notes.")
              }
              completion(error)
          }
      }
  
  

//      func deleteNote(note: Note, folderID: String, completion: @escaping (Error?) -> Void) {
//          guard let noteID = note.id else {
//              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing."]))
//              return
//          }
//          
//          let batch = db.batch()
//          let folderRef = db.collection(folderCollection).document(folderID)
//          batch.updateData(["notes": FieldValue.arrayRemove([noteID])], forDocument: folderRef)
//          
//          let noteRef = db.collection(noteCollection).document(noteID)
//          batch.deleteDocument(noteRef)
//          
//          batch.commit { error in
//              if let error = error {
//                  print("Error deleting note: \(error.localizedDescription)")
//              } else {
//                  print("Successfully deleted note \(noteID).")
//              }
//              completion(error)
//          }
//      }
  
  
  func deleteNote(note: Note, folderID: String?, completion: @escaping (Error?) -> Void) {
      guard let noteID = note.id else {
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing."]))
          return
      }
      
      let batch = db.batch()
      
      if let folderID = folderID {
          // If folderID is provided, remove note from the folder's notes
          let folderRef = db.collection(folderCollection).document(folderID)
          batch.updateData(["notes": FieldValue.arrayRemove([noteID])], forDocument: folderRef)
      } else {
          // If no folderID, remove note from the course's notes field
          guard let courseID = note.courseID else {
              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Course ID is missing for direct note deletion."]))
              return
          }
          let courseRef = db.collection(courseCollection).document(courseID)
          batch.updateData(["notes": FieldValue.arrayRemove([noteID])], forDocument: courseRef)
      }
      
      // Delete the note document itself
      let noteRef = db.collection(noteCollection).document(noteID)
      batch.deleteDocument(noteRef)
      
      // Commit the batch
      batch.commit { error in
          if let error = error {
              print("Error deleting note: \(error.localizedDescription)")
          } else {
              print("Successfully deleted note \(noteID).")
          }
          completion(error)
      }
  }


        // update methods
    func updateNoteContent(noteID: String, newContent: String) {
        let noteRef = db.collection(noteCollection).document(noteID)
        
        noteRef.updateData(["content": newContent]) { error in
            if let error = error {
                print("Error updating note: \(error.localizedDescription)")
            } else {
                print("Note successfully updated")
                if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
                    self.notes[index].content = newContent
                }
            }
        }
    }
  
func updateNoteContentCompletion(note: Note, newContent: String, completion: @escaping (Note?) -> Void) {
        let noteID = note.id ?? ""
        let noteRef = db.collection(noteCollection).document(noteID)
        
        noteRef.updateData(["content": newContent]) { error in
                if let error = error {
                        print("Error updating note: \(error.localizedDescription)")
                        completion(nil)
                } else {
                        print("Note successfully updated")
                        if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
                                self.notes[index].content = newContent
                                completion(self.notes[index])
                        }
                }
        }
}

  func updateNoteImages(note: Note, imagePath: String, completion: @escaping (Note?) -> Void) {
      let noteID = note.id ?? ""
      let noteRef = db.collection(noteCollection).document(noteID)
      
        var images = note.images
        images.append(imagePath)
        
        noteRef.updateData(["images": images]) { error in
            if let error = error {
                print("Error updating note images: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("Note images successfully updated")
                if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
                    self.notes[index].images = images
                    completion(self.notes[index])
                }
            }
        }
    }
  
  
  func getDirectNotesForCourse(courseID: String, completion: @escaping ([Note]) -> Void) {
      db.collection(noteCollection)
          .whereField("courseID", isEqualTo: courseID)
          .whereField("folderID", isEqualTo: "") // Filter for direct notes without folders
          .addSnapshotListener { querySnapshot, error in
              if let error = error {
                  print("Error fetching direct notes: \(error.localizedDescription)")
                  completion([])
                  return
              }
              
              let directNotes = querySnapshot?.documents.compactMap { document in
                  try? document.data(as: Note.self)
              } ?? []
              
              completion(directNotes)
          }
  }
  
  
  
  func listenToDirectNotesForCourse(courseID: String, completion: @escaping ([Note]) -> Void) {
          db.collection("Note")
              .whereField("courseID", isEqualTo: courseID)
              .whereField("folderID", isEqualTo: NSNull())  // Filter to only get notes outside folders
              .addSnapshotListener { querySnapshot, error in
                  if let error = error {
                      print("Error fetching direct notes: \(error.localizedDescription)")
                      completion([])  // Return an empty array if there's an error
                      return
                  }
                  
                  let notes = querySnapshot?.documents.compactMap { document in
                      try? document.data(as: Note.self)
                  } ?? []
                  
                  completion(notes)  // Pass the real-time notes data to the view model
              }
      }



  
  
  





}
