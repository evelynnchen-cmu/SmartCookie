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
  private let openAI = OpenAI()
  
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
//      for course in self.courses {
//      }
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
//      for note in self.notes {
//      }
    }
  }
  
  
  
  func getFolders(completion: @escaping ([Folder]) -> Void) {
      db.collection(folderCollection).addSnapshotListener { querySnapshot, error in
          if let error = error {
              print("Error fetching folders: \(error.localizedDescription)")
              completion([])
              return
          }

          let folders = querySnapshot?.documents.compactMap { document in
              try? document.data(as: Folder.self)
          } ?? []

          print("Total folders fetched: \(folders.count)")
//          for folder in folders {
//          }

          completion(folders)
      }
      
      let folders = querySnapshot?.documents.compactMap { document in
        try? document.data(as: Folder.self)
      } ?? []
      
      print("Total folders fetched: \(folders.count)")
      for folder in folders {
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
  
  
  
  func createNote(
      title: String,
      summary: String,
      content: String,
      images: [String] = [],
      course: Course,
      folder: Folder? = nil,
      completion: @escaping (Error?) -> Void
    // completion: @escaping (Result<String, Error>) -> Void
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
  
  // Doesn't require course or folder objects, returns the new note created, autogenerates summary
  func createNoteSimple(title: String, content: String, images: [String] = [],
                        courseID: String, folderID: String?, userID: String,
                        completion: @escaping (Note?) -> Void) async {
    // Generate a summary from the content
    do {
      let summary = try await openAI.summarizeContent(content: content)
      
      // Create a new Note object
      let note = Note(
        id: nil,
        userID: userID,
        title: title,
        summary: summary,
        content: content,
        images: images,
        createdAt: Date(),
        courseID: courseID,
        fileLocation: "\(courseID)/\(folderID ?? "")",
        lastAccessed: nil
      )
      
      let ref = try db.collection(noteCollection).addDocument(from: note)
      
      if let folderID = folderID {
        // Add note ID to the specified folder
        db.collection(folderCollection).document(folderID).updateData([
          "notes": FieldValue.arrayUnion([ref.documentID])
        ]) { error in
          if let error = error {
            print("Error updating folder: \(error)")
            completion(nil)
          } else {
            var newNote = note
            newNote.id = ref.documentID
            completion(newNote)
          }
        }
      } else {
        db.collection(courseCollection).document(courseID).updateData([
          "notes": FieldValue.arrayUnion([ref.documentID])
        ]) { error in
          if let error = error {
            print("Error updating course: \(error)")
            completion(nil)
          } else {
            var newNote = note
            newNote.id = ref.documentID
            completion(newNote)
          }
        }
      }
    } catch {
      print("Error creating note: \(error)")
      completion(nil)
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
  
  
  
  
  func deleteNote(note: Note, folderID: String?, completion: @escaping (Error?) -> Void) {
    guard let noteID = note.id else {
      completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Note ID is missing."]))
      return
    }
    
    let batch = db.batch()
    
    if let folderID = folderID {
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
    
    let noteRef = db.collection(noteCollection).document(noteID)
    batch.deleteDocument(noteRef)
    
    batch.commit { error in
      if let error = error {
        print("Error deleting note: \(error.localizedDescription)")
      } else {
        print("Successfully deleted note \(noteID).")
      }
      completion(error)
    }
  }
  
  func updateNoteSummary(noteID: String, newSummary: String) {
    let noteRef = db.collection(noteCollection).document(noteID)
    
    noteRef.updateData(["summary": newSummary]) { error in
      if let error = error {
        print("Error updating note summary: \(error.localizedDescription)")
      } else {
        print("Note summary successfully updated")
        if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
          self.notes[index].summary = newSummary
        }
      }
    }
  }
    
    
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
    
    func toggleNotesOnlyChatScope(isEnabled: Bool, completion: @escaping (Error?) -> Void) {
      self.getFirstUser { user in
        guard let user = user else {
          print("No user found")
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
          return
        }
        
        let userRef = self.db.collection(self.userCollection).document(user.id!)
        
        userRef.updateData([
          "settings.notesOnlyChatScope": isEnabled
        ]) { error in
          if let error = error {
            print("Error updating notesOnlyChatScope: \(error.localizedDescription)")
            completion(error)
          } else {
            print("Successfully toggled notesOnlyChatScope to \(isEnabled)")
            completion(nil)
          }
        }
      }
    }
    
    func getCourse(courseID: String, completion: @escaping (Course?) -> Void) {
      db.collection(courseCollection).document(courseID).addSnapshotListener { documentSnapshot, error in
        if let error = error {
          print("Error fetching course by ID: \(error.localizedDescription)")
          completion(nil)
          return
        }
        
        guard let document = documentSnapshot, document.exists else {
          print("Course not found for ID: \(courseID)")
          completion(nil)
          return
        }
        
        if let course = try? document.data(as: Course.self) {
          print("Course fetched with ID: \(course.id ?? "No ID")")
          completion(course)
        } else {
          print("Failed to parse course data for ID: \(courseID)")
          completion(nil)
        }
      }
    }
    
    func toggleNotesOnlyQuizScope(isEnabled: Bool, completion: @escaping (Error?) -> Void) {
      self.getFirstUser { user in
        guard let user = user else {
          print("No user found")
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
          return
        }
        
        let userRef = self.db.collection(self.userCollection).document(user.id!)
        
        userRef.updateData([
          "settings.notesOnlyQuizScope": isEnabled
        ]) { error in
          if let error = error {
            print("Error updating notesOnlyQuizScope: \(error.localizedDescription)")
            completion(error)
          } else {
            print("Successfully toggled notesOnlyQuizScope to \(isEnabled)")
            completion(nil)
          }
        }
      }
    }
    
    func toggleNotificationsEnabled(isEnabled: Bool, completion: @escaping (Error?) -> Void) {
      self.getFirstUser { user in
        guard let user = user else {
          print("No user found")
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
          return
        }
        
        let userRef = self.db.collection(self.userCollection).document(user.id!)
        
        userRef.updateData([
          "settings.notificationsEnabled": isEnabled
        ]) { error in
          if let error = error {
            print("Error updating notificationsEnabled: \(error.localizedDescription)")
            completion(error)
          } else {
            print("Successfully toggled notifications to \(isEnabled)")
            completion(nil)
          }
        }
      }
    }
    
    func updateNotificationFrequency(_ frequency: String, completion: @escaping (Error?) -> Void) {
      let validFrequencies = [
        "3x per week",    // Mon/Wed/Fri pattern
        "2x per week",          // Tue/Thu pattern
        "Weekly",                  // For lighter study loads
        "Daily"                    // For intensive study periods
      ]
      
      guard validFrequencies.contains(frequency) else {
        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid frequency value"]))
        return
      }
      
      self.getFirstUser { user in
        guard let user = user else {
          print("No user found")
          completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
          return
        }
        
        let userRef = self.db.collection(self.userCollection).document(user.id!)
        
        userRef.updateData([
          "settings.notificationFrequency": frequency
        ]) { error in
          if let error = error {
            print("Error updating notificationFrequency: \(error.localizedDescription)")
            completion(error)
          } else {
            print("Successfully updated notification frequency to \(frequency)")
            completion(nil)
          }
        }
      }
    }
    
  }

  func getFolder(folderID: String, completion: @escaping (Folder?) -> Void) {
        db.collection(folderCollection).document(folderID).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching folder by ID: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("Folder not found for ID: \(folderID)")
                completion(nil)
                return
            }
            
            if let folder = try? document.data(as: Folder.self) {
                print("Folder fetched with ID: \(folder.id ?? "No ID")")
                completion(folder)
            } else {
                print("Failed to parse folder data for ID: \(folderID)")
                completion(nil)
            }
        }
    }

    func getNotesById(noteIDs: [String], completion: @escaping ([Note]) -> Void) {
        let notesRef = db.collection(noteCollection)
        var notes: [Note] = []
        
        for noteID in noteIDs {
            notesRef.document(noteID).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching note by ID: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("Note not found for ID: \(noteID)")
                    return
                }
                
                if let note = try? document.data(as: Note.self) {
                    notes.append(note)
                } else {
                    print("Failed to parse note data for ID: \(noteID)")
                }
                
                if notes.count == noteIDs.count {
                    completion(notes)
                }
            }
        }
    }

}
