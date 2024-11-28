//
//  TextParseViewNewNote.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/14/24.
//

import SwiftUI

struct TextParserView: View {
  var image: UIImage
  var firebaseStorage: FirebaseStorage = FirebaseStorage()
  var firebase: Firebase
  @Binding var isPresented: Bool
  @State private var selectedImage: UIImage? = nil
  @State private var alertMessage = ""
  @State private var showAlert = false
  @State private var navigateToNoteView = false
  @State private var isChatViewPresented: Bool? = false
  var course: Course?
  var title: String
  @Binding var note: Note?
  @State private var courseID: String = ""
  @State private var userID: String = ""
  @State private var content: String? = nil
  @State private var newNote: Note? = nil
  private var openAI = OpenAI()
  
  var completion: ((String) -> Void)?

  init(image: UIImage, firebase: Firebase, isPresented: Binding<Bool>, course: Course?, title: String, note: Binding<Note?>? = .constant(nil), completion: ((String) -> Void)? = nil) {
        self.image = image
        self.firebase = firebase
        self._isPresented = isPresented
        self.course = course
        self.title = title
        self._note = note ?? .constant(nil) // Set to nil if not provided
        self.completion = completion
    }
  
    var body: some View {
      VStack {
        HStack {
          Spacer()
          Button(action: {
            isPresented = false
          }) {
            Image(systemName: "xmark")
                .foregroundColor(.black)
                .padding()
          }
        }
        
        ScrollView {
          if let text = content {
            if (text.isEmpty) {
              Text("No text found")
              .padding()
            }
            else {
              Text(text)
                  .padding()
            }
          } else {
            ProgressView("Parsing text...")
              .padding()
          }
        }
        
        Spacer()
        
        HStack {
            Button(action: {
                // Action to save the parsed text
                firebaseStorage.uploadImageToFirebase(image) { path in
                  if let imagePath = path {
                    print("Image path: \(imagePath)")
                    if let thisNote = self.note {
                        // Update the note document in firebase with the new file path
                        firebase.updateNoteImages(note: thisNote, imagePath: imagePath) { updatedNote in
                            if let updatedNote = updatedNote {
                              self.note = updatedNote
                              if let content = content {
                                var combinedContent = (thisNote.content) + "\n" + content
                                firebase.updateNoteContentCompletion(note: updatedNote, newContent: combinedContent) { updatedNote in
                                  if let updatedNote = updatedNote {
                                    self.note = updatedNote
                                    // let summary = try await summarizeContent(content: content)
//                                    var updatedSummary = combinedContent
//                                     Task {
//                                      print("doing task!")
//                                      do {
//                                        updatedSummary = try await openAI.summarizeContent(content: combinedContent)
//                                        print("new summary done")
//                                      } catch {
//                                        print("Failed to summarize content")
//                                        alertMessage = "Failed to summarize content"
//                                        showAlert = true
//                                      }
//                                     }
//                                    print("calling updateNoteSummary")
                                     firebase.updateNoteSummary(note: updatedNote, newSummary: content) { updatedNote in
//                                    firebase.updateNoteSummary(note: updatedNote, newSummary: updatedSummary) { updatedNote in
                                      if let updatedNote = updatedNote {
                                        self.note = updatedNote
                                        completion?("\nNote updated successfully!")
                                        showAlert = false
                                        isPresented = false
                                      }
                                      else {
                                        print("Failed to update summary")
                                        alertMessage = "Failed to update summary"
                                        showAlert = true
                                      }
                                    }
                                  } else {
                                    print("Failed to update note with parsed image content")
                                    alertMessage = "Failed to update note with parsed image content"
                                    showAlert = true
                                  }
                                }
                              }
                            } else {
                                print("Failed to update note with image path")
                                alertMessage = "Failed to update note with image"
                                showAlert = true
                            }
                      }
                    }
                    else {
                      if let course = course {
                        print("Course ID: \(course.id)")
                        courseID = course.id ?? ""
                        userID = course.userID
                        
                        var noteTitle = title.isEmpty ? "\(imagePath)" : title
                        
                        Task {
                          await firebase.createNoteSimple(
                            title: noteTitle,
                            content: content ?? "",
                            images: [imagePath],
                            courseID: courseID,
                            folderID: nil,
                            userID: userID
                          ) { note in
                            if let note = note {
                              print("Note created: \(note.id)")
                              newNote = note
                              completion?("\nNote \(newNote?.title ?? "Unknown Name") created successfully!")
                              showAlert = false
                              isPresented = false
                            } else {
                              print("Failed to create note")
                              alertMessage = "Failed to create note"
                              showAlert = true
                            }
                          }
                        }
                      } else {
                        print("Failed to get course")
                        alertMessage = "Failed to get course"
                        showAlert = true
                      }
                    }
                    
                    }
                    else {
                      print("Failed to upload image")
                      alertMessage = "Failed to upload image"
                      showAlert = true
                    }
                }
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // Action to re-extract the text
                self.content = nil
                openAI.parseImage(image) { text in
                  if let parsedText = text {
                    print("Parsed image content: \(parsedText)")
                    self.content = parsedText
                  }
                  else {
                    print("Failed to parse image")
                  }
                }
            }) {
                Text("Re-extract")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
              isChatViewPresented = true
            }) {
                Text("Chat Now")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
          }
          .padding()
    }
    .onAppear {
//        Parse image
        openAI.parseImage(image) { text in
          if let parsedText = text {
            print("Parsed image content: \(parsedText)")
            self.content = parsedText
          }
          else {
            print("Failed to parse image")
          }
        }
    }
    .alert(isPresented: $showAlert) {
        Alert(title: Text("Image Upload"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }
    .fullScreenCover(isPresented: Binding(
        get: { isChatViewPresented ?? false },
        set: { isChatViewPresented = $0 ? true : nil }
    )) {
      if let course = course {
        ChatView(selectedCourse: course, isChatViewPresented: $isChatViewPresented)
      }
      else {
        Text("Failed to load course")
      }
    }
  }
}
