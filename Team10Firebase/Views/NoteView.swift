
import SwiftUI
import PhotosUI

struct NoteView: View {
  private var firebaseStorage: FirebaseStorage
  @StateObject private var viewModel: NoteViewModel
  @ObservedObject var firebase: Firebase
  @State private var isPickerPresented = false
  @State private var selectedImage: UIImage? = nil
  @State private var alertMessage = ""
  @State private var showAlert = false
  var note: Note
  
  init(firebase: Firebase, note: Note) {
    _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
    self.note = note
    self.firebaseStorage = FirebaseStorage()
    self.firebase = firebase
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 8) {
        Text("Note ID: \(note.id ?? "N/A")")
          .font(.body)
        Text("User ID: \(note.userID ?? "N/A")")
          .font(.body)
        Text("Title: \(note.title)")
          .font(.title)
          .fontWeight(.bold)
        Text("Summary: \(note.summary)")
          .font(.body)
          .foregroundColor(.gray)
        Text("Content: \(note.content)")
          .font(.body)
        Text("Images: \(note.images.isEmpty ? "No images" : "\(note.images.count) image(s)")")
          .font(.body)
        Text("Created At: \(note.createdAt, formatter: dateFormatter)")
          .font(.body)
        Text("Course ID: \(note.courseID ?? "N/A")")
          .font(.body)
        Text("File Location: \(note.fileLocation)")
          .font(.body)
        Text("Last Accessed: \(note.lastAccessed ?? Date(), formatter: dateFormatter)")
          .font(.body)
          .foregroundColor(.secondary)
        
        // Displays images associated with this note - should probably change to onAppear
        // and refactor firebaseStorage to not store its state
        if viewModel.isLoading {
          ProgressView("Loading...")
        } else if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .foregroundColor(.red)
        } else if viewModel.images.isEmpty {
          Text("No images available")
        } else {
//          ScrollView(.horizontal) {
//            HStack {
          VStack {
              ForEach(viewModel.images, id: \.self) { image in
                Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 200, height: 200)
                  .padding()
              }
            }
//          }
        }
        
        // Button to upload photos
        Button(action: {
          isPickerPresented = true
        }) {
          Text("Upload Image from Photo Library")
            .font(.body)
            .foregroundColor(.blue)
        }
        // Button to downloadImage from firebase
        //   Button(action: firebaseStorage.downloadImage) {
        //                   Text("Download Image")
        //                       .padding()
        //                       .background(Color.blue)
        //                       .foregroundColor(.white)
        //                       .cornerRadius(10)
        //               }        }
        
//        Button(action: viewModel.loadImages) {
//          Text("Load Images")
//            .padding()
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
      }
        .padding(.leading)
        .sheet(isPresented: $isPickerPresented) {
          ImagePicker(sourceType: .photoLibrary) { image in
            self.selectedImage = image
            // firebaseStorage.uploadImageToFirebase(image) { url in
            //   if let downloadURL = url {
            //       print("Download URL: \(downloadURL)")
            //       alertMessage = "Image uploaded successfully! URL: \(downloadURL)"
            //       // Update the note document in firebase with the new file path
            //     //   firebase.updateNoteImages(noteID: note.id!, images: [downloadURL.absoluteString])
            //       firebase.updateNoteImages(noteID: note.id!, images: [])
            //   } else {
            //       print("Failed to upload image")
            //       alertMessage = "Failed to upload image"
            //   }
            //   showAlert = true
            // }
            firebaseStorage.uploadImageToFirebase(image) { path in
              if let imagePath = path {
                print("Image path: \(imagePath)")
                alertMessage = "Image uploaded successfully! Path: \(imagePath)"
                // Update the note document in firebase with the new file path
                //   firebase.updateNoteImages(noteID: note.id!, images: [downloadURL.absoluteString])
                print("note before update", note.images)
                firebase.updateNoteImages(note: note, imagePath: imagePath) { updatedNote in
                    if let updatedNote = updatedNote {
                        viewModel.note = updatedNote
                        viewModel.loadImages() // Fetch images again to update the view
                    } else {
                        print("Failed to update note with image path")
                    }
                }
              } else {
                print("Failed to upload image")
                alertMessage = "Failed to upload image"
              }
              showAlert = true
            }
            firebaseStorage.parseImage(image)
          }
        }
        .alert(isPresented: $showAlert) {
          Alert(title: Text("Image Upload"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        // To avoid reloading images more than once
        .onAppear {
            if (!viewModel.imagesLoaded) {
                viewModel.loadImages()
            }
        }
      }
      .navigationTitle(note.title)
    }
  }
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()



