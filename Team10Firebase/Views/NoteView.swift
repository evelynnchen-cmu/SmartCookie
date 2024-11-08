
import SwiftUI
import PhotosUI

struct NoteView: View {
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage? = nil
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
          // Button to upload photos
          Button(action: {
            isPickerPresented = true
          }) {
            Text("Upload Image from Photo Library")
              .font(.body)
              .foregroundColor(.blue)
          }
          .padding(.top)
        }
        .padding(.leading)
        .sheet(isPresented: $isPickerPresented) {
          ImagePicker(sourceType: .photoLibrary) { image in
            self.selectedImage = image
            uploadImageToFirebase(image)
            parseImage(image)
          }
        }
      }
      .navigationTitle(note.title)
    }
}

private func uploadImageToFirebase(_ image:UIImage) {
  print("Unimplemented upload image to Firebase")
}

private func parseImage(_ image:UIImage) {
  print("Unimplemented parse image")
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
