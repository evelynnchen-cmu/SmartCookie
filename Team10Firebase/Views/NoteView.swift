
import SwiftUI
import PhotosUI

struct NoteView: View {
//    var firebaseStorage: FirebaseStorage = FirebaseStorage()
    @StateObject private var firebaseStorage = FirebaseStorage()
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var alertMessage = ""
    @State private var showAlert = false
    var note: Note

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
          
          if firebaseStorage.isLoading {
              ProgressView("Loading...")
          } else if let image = firebaseStorage.image {
              Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 200, height: 200)
          } else if let errorMessage = firebaseStorage.errorMessage {
              Text(errorMessage)
                  .foregroundColor(.red)
          } else {
              Text("No image available")
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
          Button(action: firebaseStorage.downloadImage) {
                          Text("Download Image")
                              .padding()
                              .background(Color.blue)
                              .foregroundColor(.white)
                              .cornerRadius(10)
                      }
          .padding(.top)
        }
        .padding(.leading)
        .sheet(isPresented: $isPickerPresented) {
          ImagePicker(sourceType: .photoLibrary) { image in
            self.selectedImage = image
            firebaseStorage.uploadImageToFirebase(image) { url in
              if let downloadURL = url {
                  print("Download URL: \(downloadURL)")
                  // Handle the download URL (e.g., save it, display it, etc.)
                  alertMessage = "Image uploaded successfully! URL: \(downloadURL)"
                  // 
                
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
