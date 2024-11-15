//
//  TextParserView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct TextParserView: View {
  var image: UIImage
  var firebaseStorage: FirebaseStorage = FirebaseStorage()
  @StateObject var viewModel: NoteViewModel
  @ObservedObject var firebase: Firebase
  @Binding var isPresented: Bool
  @State private var selectedImage: UIImage? = nil
  @State private var alertMessage = ""
  @State private var showAlert = false
  @State private var navigateToNoteView = false
  @State private var parsedText: String? = nil
  @State private var isChatViewPresented: Bool? = false
  var note: Note
  var completion: ((String) -> Void)?
  
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
          if let text = parsedText {
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
                    // Update the note document in firebase with the new file path
                    firebase.updateNoteImages(note: note, imagePath: imagePath) { updatedNote in
                        if let updatedNote = updatedNote {
                          viewModel.note = updatedNote
                          viewModel.loadImages() // Fetch images again to update the view
                          if let content = parsedText {
                            firebase.updateNoteContentCompletion(note: note, newContent: content) { updatedNote in
                              if let updatedNote = updatedNote {
                                viewModel.note = updatedNote
                                completion?("\nNote updated successfully!")
                                showAlert = false
                                isPresented = false
                                
//                                firebase.updateNoteSummary(note: updatedNote, newSummary: content) { updatedNote in
//                                  if let updatedNote = updatedNote {
//                                    viewModel.note = updatedNote
//                                    
//                                  }
//                                  else {
//                                    print("Failed to update summary")
//                                    alertMessage = "Failed to update summary"
//                                    showAlert = true
//                                  }
//                                }
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
                  } else {
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
                self.parsedText = nil
                viewModel.parseImage(image) { text in
                  if let content = text {
                    print("Parsed image content: \(content)")
                    self.parsedText = content
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
       viewModel.parseImage(image) { text in
         if let content = text {
           print("Parsed image content: \(content)")
           self.parsedText = content
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
      if let course = viewModel.course {
        ChatView(selectedCourse: course, isChatViewPresented: $isChatViewPresented)
      }
      else {
        Text("Failed to load course")
      }
    }
  }
}
