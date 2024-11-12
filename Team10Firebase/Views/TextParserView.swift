//
//  TextParserView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct TextParserView: View {
    var image: UIImage
    var firebaseStorage: FirebaseStorage
    @StateObject var viewModel: NoteViewModel
    @ObservedObject var firebase: Firebase
    @Binding var isPresented: Bool
    @State private var selectedImage: UIImage? = nil
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var navigateToNoteView = false
    @State private var parsedText: String? = nil
  var note: Note
  
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
                                alertMessage += "\nNote updated successfully!"
                                isPresented = false
                              } else {
                                print("Failed to update note with parsed image content")
                              }
                            }
                          }
                        } else {
                            print("Failed to update note with image path")
                        }
                    }
                  } else {
                    print("Failed to upload image")
                    alertMessage = "Failed to upload image"
                  }
                }
                showAlert = true
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // Action to re-extract the text
            }) {
                Text("Re-extract")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
//              firebase.getCourse(courseID: note.courseID ?? "") {foundCourse in
//                if let course = foundCourse {
//                  ChatView(course)
//                } else {
//                  print("Failed to get course")
//                }
//              }
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
  }
}

//#Preview {
//    TextParserView()
//}
