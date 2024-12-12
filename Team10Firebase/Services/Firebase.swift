//
//  Firebase.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

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
    // completion: @escaping (Error?) -> Void
    completion: @escaping (Note?, Error?) -> Void
  ) {
    guard let courseID = course.id else {
      completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid course ID"]))
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
      lastAccessed: Date(),
      lastUpdated: Date()
    )
    
    do {
      let ref = try db.collection(noteCollection).addDocument(from: note)
      
      if let folder = folder {
        // Add note ID to the specified folder
        db.collection(folderCollection).document(folder.id ?? "").updateData([
          "notes": FieldValue.arrayUnion([ref.documentID])
        ]) { error in
          if let error = error {
            completion(nil, error)
          } else {
              var createdNote = note
              createdNote.id = ref.documentID
              completion(createdNote, nil)
          }
        }
      } else {
        db.collection(courseCollection).document(courseID).updateData([
          "notes": FieldValue.arrayUnion([ref.documentID])
        ]) { error in
          if let error = error {
              completion(nil, error)
          } else {
              var createdNote = note
              createdNote.id = ref.documentID
              completion(createdNote, nil)
          }
        }
      }
    } catch {
      print("Error creating note: \(error)")
      completion(nil, error)
    }
  }
  
  // Doesn't require course or folder objects, returns the new note created, autogenerates summary
  func createNoteWithIDs(title: String, content: String, images: [String] = [],
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
        // lastAccessed: nil
        lastAccessed: Date(),
        lastUpdated: Date()
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
  
 
func deleteCourse(courseID: String, completion: @escaping (Error?) -> Void) {
    var allNoteIDs: [String] = []
    var imagePaths: [String] = []

    let batch = db.batch()
    let courseRef = db.collection("Course").document(courseID)

    // Fetch the course document to get the notes
    courseRef.getDocument { (document, error) in
        if let document = document, document.exists, let course = try? document.data(as: Course.self) {
            allNoteIDs.append(contentsOf: course.notes)
        }

        let folderQuery = self.db.collection("Folder").whereField("courseID", isEqualTo: courseID)
        folderQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching folders: \(error.localizedDescription)")
                completion(error)
                return
            }

            guard let folderDocuments = querySnapshot?.documents else {
                print("No folders found for course.")
                completion(nil)
                return
            }

            let dispatchGroup = DispatchGroup()

            for folderDoc in folderDocuments {
                let folderID = folderDoc.documentID

                if let folder = try? folderDoc.data(as: Folder.self) {
                    allNoteIDs.append(contentsOf: folder.notes)
                }

                let folderRef = self.db.collection("Folder").document(folderID)
                batch.deleteDocument(folderRef)
            }

            for noteID in allNoteIDs {
                dispatchGroup.enter()
                let noteRef = self.db.collection("Note").document(noteID)
                noteRef.getDocument { document, error in
                    if let document = document, document.exists, let data = document.data() {
                        if let images = data["images"] as? [String] {
                            imagePaths.append(contentsOf: images)
                        }
                    }
                    batch.deleteDocument(noteRef)
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Delete images from Firebase Storage
                self.deleteImages(imagePaths: imagePaths) { error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    // Delete the course document
                    batch.deleteDocument(courseRef)

                    // Commit the batch after images are deleted
                    batch.commit { error in
                        if let error = error {
                            print("Error committing batch delete: \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted course \(courseID) and all associated data.")
                        }
                        self.getCourses()
                        completion(error)
                    }
                }
            }
        }
    }
}

  func deleteFolder(folder: Folder, courseID: String, completion: @escaping (Error?) -> Void) {
    guard let folderID = folder.id else {
      completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Folder ID is missing."]))
      return
    }
    
    let batch = db.batch()
    var imagePaths: [String] = []

    let dispatchGroup = DispatchGroup()
    
    folder.notes.forEach { noteID in
      dispatchGroup.enter()
      let noteRef = db.collection(noteCollection).document(noteID)
      noteRef.getDocument { document, error in
          if let document = document, document.exists, let data = document.data() {
              if let images = data["images"] as? [String] {
                  imagePaths.append(contentsOf: images)
              }
          }
          batch.deleteDocument(noteRef)
          dispatchGroup.leave()
      }
    }

    dispatchGroup.notify(queue: .main) {
      // Delete images from Firebase Storage
      self.deleteImages(imagePaths: imagePaths) { error in
          if let error = error {
              completion(error)
              return
          }
          
        // Update course and delete folder
        let courseRef = self.db.collection(self.courseCollection).document(courseID)
        batch.updateData(["folders": FieldValue.arrayRemove([folderID])], forDocument: courseRef)
        
        let folderRef = self.db.collection(self.folderCollection).document(folderID)
        batch.deleteDocument(folderRef)
        
        // Commit the batch after images are deleted
        batch.commit { error in
            if let error = error {
                print("Error deleting folder: \(error.localizedDescription)")
            } else {
                print("Successfully deleted folder \(folderID) and its notes.")
            }
            completion(error)
        }
      }
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

    let imagePaths = note.images ?? []
    
    // Delete images from Firebase Storage
    deleteImages(imagePaths: imagePaths) { error in
        if let error = error {
            completion(error)
            return
        }
        
        // Commit the batch after images are deleted
        batch.commit { error in
            if let error = error {
                print("Error deleting note: \(error.localizedDescription)")
            } else {
                print("Successfully deleted note \(noteID).")
            }
            completion(error)
        }
    }
  }

  func deleteImages(imagePaths: [String], completion: @escaping (Error?) -> Void) {
    let storage = Storage.storage()
    let dispatchGroup = DispatchGroup()
    var deletionError: Error?

    for imagePath in imagePaths {
        dispatchGroup.enter()
        let storageRef = storage.reference(withPath: imagePath)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image: \(error.localizedDescription)")
                deletionError = error
            } else {
                print("Successfully deleted image: \(imagePath)")
            }
            dispatchGroup.leave()
        }
    }

    dispatchGroup.notify(queue: .main) {
        completion(deletionError)
    }
}
  
  func updateNoteSummary(note: Note, newSummary: String, completion: @escaping (Note?) -> Void) {
    let noteID = note.id ?? ""
    let noteRef = db.collection(noteCollection).document(noteID)
    
    noteRef.updateData(["summary": newSummary]) { error in
        if let error = error {
            print("Error updating note summary: \(error.localizedDescription)")
            completion(nil)
        } else {
            print("Note summary successfully updated")
            if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
                self.notes[index].summary = newSummary
                completion(self.notes[index])
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

    func updateNoteImages(note: Note, imagePaths: [String], completion: @escaping (Note?) -> Void) {
      let noteID = note.id ?? ""
      let noteRef = db.collection(noteCollection).document(noteID)
      
      var images = note.images
      images.append(contentsOf: imagePaths)

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
        "3x per week",
        "2x per week",
        "Weekly",
        "Daily"
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
  
  func handleQuestionResult(
      question: MCQuestion,
      isCorrect: Bool,
      userID: String,
      noteID: String,
      completion: @escaping (Error?) -> Void
  ) {
      let query = db.collection(mcQuestionCollection)
          .whereField("userID", isEqualTo: userID)
          .whereField("noteID", isEqualTo: noteID)
          .whereField("question", isEqualTo: question.question)
      
      query.getDocuments { [weak self] (snapshot, error) in
          if let error = error {
              completion(error)
              return
          }
          
          if let existingDoc = snapshot?.documents.first {
              if isCorrect {
                  // Delete question if answered correctly
                  existingDoc.reference.delete { error in
                      completion(error)
                  }
              } else {
                  // Increment attempt count if answered incorrectly
                  let currentAttempts = (try? existingDoc.data(as: MCQuestion.self))?.attemptCount ?? 0
                  existingDoc.reference.updateData([
                      "attemptCount": currentAttempts + 1,
                      "lastAttemptDate": Date()
                  ]) { error in
                      completion(error)
                  }
              }
          } else if !isCorrect {
              // Only save new incorrect questions
              var newQuestion = question
              newQuestion.userID = userID
              newQuestion.noteID = noteID
              newQuestion.attemptCount = 1
              newQuestion.lastAttemptDate = Date()
              
              do {
                  try self?.db.collection(self?.mcQuestionCollection ?? "").addDocument(from: newQuestion)
                  completion(nil)
              } catch {
                  completion(error)
              }
          } else {
              // Correct answer for new question, no action needed
              completion(nil)
          }
      }
  }
  
  func getIncorrectQuestions(userID: String, noteID: String, completion: @escaping ([MCQuestion]) -> Void) {
      db.collection(mcQuestionCollection)
          .whereField("userID", isEqualTo: userID)
          .whereField("noteID", isEqualTo: noteID)
          .getDocuments { (snapshot, error) in
              if let error = error {
                  print("Error fetching incorrect questions: \(error)")
                  completion([])
                  return
              }
              
              let questions = snapshot?.documents.compactMap { doc -> MCQuestion? in
                  try? doc.data(as: MCQuestion.self)
              } ?? []
              
              completion(questions)
          }
  }
  
  func updateUserStreak(userID: String, quizScore: Int, completion: @escaping (Error?) -> Void) {
      let userRef = db.collection(userCollection).document(userID)
      
      userRef.getDocument { (document, error) in
          if let error = error {
              completion(error)
              return
          }
          
          guard let document = document,
                let user = try? document.data(as: User.self) else {
              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
              return
          }
          
          guard quizScore >= 80 else {
              // don't need to update if quiz score is < 80
              completion(nil)
              return
          }
          
          let currentDate = Date()
          
          // If this is the first quiz completion
          if user.streak.lastQuizCompletedAt == nil {
              userRef.updateData([
                  "streak.currentStreakLength": 1,
                  "streak.lastQuizCompletedAt": currentDate
              ]) { error in
                  completion(error)
              }
              return
          }
          
          // to compare dates
          let calendar = Calendar.current
          
          guard let lastQuizDate = user.streak.lastQuizCompletedAt else {
              completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid last quiz date"]))
              return
          }
          
          // Check if the last quiz was completed today
          let isToday = calendar.isDate(lastQuizDate, inSameDayAs: currentDate)
          if isToday {
              completion(nil) // no need to update streak
              return
          }
          
          // Check if the last quiz was completed yesterday
          let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate)!
          let wasYesterday = calendar.isDate(lastQuizDate, inSameDayAs: yesterday)
          
          // Update streak based on timing
          let newStreakLength = wasYesterday ? user.streak.currentStreakLength + 1 : 1
          
          userRef.updateData([
              "streak.currentStreakLength": newStreakLength,
              "streak.lastQuizCompletedAt": currentDate
          ]) { error in
              completion(error)
          }
      }
  }

    func getFoldersById(folderIDs: [String], completion: @escaping ([Folder]) -> Void) {
      let foldersRef = db.collection("Folder") // Adjust collection name if needed
      var folders: [Folder] = []
      
      for folderID in folderIDs {
          foldersRef.document(folderID).getDocument { documentSnapshot, error in
              if let error = error {
                  print("Error fetching folder by ID: \(error.localizedDescription)")
                  return
              }
              
              guard let document = documentSnapshot, document.exists else {
                  print("Folder not found for ID: \(folderID)")
                  return
              }
              
              if let folder = try? document.data(as: Folder.self) {
                  folders.append(folder)
              } else {
                  print("Failed to parse folder data for ID: \(folderID)")
              }
              
              // Call the completion block once all folder IDs have been processed
              if folders.count == folderIDs.count {
                  completion(folders)
              }
          }
      }
    }
  
  
  // Add this method to your Firebase class
  func updateCourseName(courseID: String, newName: String, completion: @escaping (Error?) -> Void) {
      let courseRef = db.collection(courseCollection).document(courseID)
      
      courseRef.updateData([
          "courseName": newName,
          "fileLocation": "/\(newName)/"
      ]) { error in
          if let error = error {
              print("Error updating course name: \(error.localizedDescription)")
              completion(error)
          } else {
              print("Course name successfully updated")
              // Refresh courses list
              self.getCourses()
              completion(nil)
          }
      }
  }
  
  
  func updateFolderName(folderID: String, newName: String, completion: @escaping (Error?) -> Void) {
      let folderRef = db.collection(folderCollection).document(folderID)
      
      folderRef.updateData([
          "folderName": newName
      ]) { error in
          if let error = error {
              print("Error updating folder name: \(error.localizedDescription)")
              completion(error)
          } else {
              print("Folder name successfully updated")
              self.getFolders { _ in }
              completion(nil)
          }
      }
  }

  func updateNoteTitle(note: Note, newTitle: String, completion: @escaping (Note?) -> Void) {
      let noteID = note.id ?? ""
      let noteRef = db.collection(noteCollection).document(noteID)
      
      noteRef.updateData([
          "title": newTitle
      ]) { error in
          if let error = error {
              print("Error updating note title: \(error.localizedDescription)")
              completion(nil)
          } else {
              print("Note title successfully updated")
              if let index = self.notes.firstIndex(where: { $0.id == noteID }) {
                  self.notes[index].title = newTitle
                  completion(self.notes[index])
              }
          }
      }
  }
  

  
  func updateNoteLastUpdated(noteID: String) {
      let noteRef = db.collection(noteCollection).document(noteID)
      
      noteRef.updateData([
          "lastUpdated": Date()
      ]) { error in
          if let error = error {
              print("Error updating note last updated: \(error.localizedDescription)")
          }
      }
  }
  
  
  
  func getMostRecentlyUpdatedNotes(limit: Int = 4) -> [Note] {
      // Sort notes by lastUpdated or createdAt if lastUpdated is nil
      let sortedNotes = notes.sorted { note1, note2 in
          let date1 = note1.lastUpdated ?? note1.createdAt
          let date2 = note2.lastUpdated ?? note2.createdAt
          return date1 > date2
      }
      
      return Array(sortedNotes.prefix(limit))
  }
  
  
  
  


}
