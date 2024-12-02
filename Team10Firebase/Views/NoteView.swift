import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import PhotosUI

struct NoteView: View {
  @StateObject var viewModel: NoteViewModel
  @ObservedObject var firebase: Firebase
  @State private var isPickerPresented = false
  @State private var isPDFPickerPresented = false
  @State private var showTextParserView = false
  @State private var selectedImage: UIImage?
  @State private var selectedPDFText: String?
  @State private var contentTab = true
  @State private var showAlert = false
  @State private var alertMessage = ""
  var note: Note
  var course: Course
  
  init(firebase: Firebase, note: Note, course: Course) {
    self.firebase = firebase
    _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
    self.note = note
    self.course = course
  }
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      ScrollView {
        VStack(alignment: .leading, spacing: 8) {
          if let note = viewModel.note {
            VStack(spacing: 8) {
              Text("Summary")
                .font(.headline)
                .foregroundColor(.primary)
              Text(note.summary)
                .font(.body) // Smaller font for the summary text
            }
            .padding(16) // Padding around the box
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2)) // Background color for the box
            )
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Button to upload photos
            Button(action: {
              isPickerPresented = true
            }) {
              Text("Upload Image from Photo Library")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(8)
            }
            
//            Spacer()
              
            // Button to upload PDFs
              Button(action: {
                isPDFPickerPresented = true
              }) {
                Text("Upload and Parse PDF")
                  .font(.headline)
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(Color.blue)
                  .foregroundColor(Color.white)
                  .cornerRadius(8)
              }
              .sheet(isPresented: $isPDFPickerPresented) {
                PDFPicker { extractedText in
                  self.selectedPDFText = extractedText
                  // Handle storing text in Firebase or displaying in the UI
                  if let text = extractedText {
                    // You can store or use the text here
                    print("Extracted PDF Text: \(text)")
                  } else {
                    self.alertMessage = "Failed to extract text from PDF."
                    self.showAlert = true
                  }
                }
              }
              .alert(isPresented: $showAlert) {
                  Alert(
                      title: Text("PDF Error"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK"))
                  )
              }
              
              Spacer()

            
            // Buttons to switch between tabs
            HStack {
              Button(action: {
                contentTab = true
              }) {
                Text("Content")
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(contentTab ? Color.blue : Color.clear)
                  .foregroundColor(contentTab ? Color.white : Color.blue)
                  .cornerRadius(8)
              }
              
              Button(action: {
                contentTab = false
              }) {
                Text("Images")
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(!contentTab ? Color.blue : Color.clear)
                  .foregroundColor(!contentTab ? Color.white : Color.blue)
                  .cornerRadius(8)
              }
            }
            .frame(maxWidth: .infinity)
            
            if (contentTab) {
              Text(note.content)
                .font(.body)
              Text("Created At: \(note.createdAt, formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
              Text("Last Accessed: \(note.lastAccessed ?? Date(), formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
            }
            else {
              if viewModel.isLoading {
                ProgressView("Loading...")
              } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                  .foregroundColor(.red)
              } else if viewModel.images.isEmpty {
                Text("No images available")
              } else {
                VStack {
                  ForEach(viewModel.images, id: \.self) { image in
                    Image(uiImage: image)
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(maxWidth: .infinity)
                      .padding()
                  }
                }
              }
            }
          } else {
            Text("Loading note...")
          }
        }
        .padding(.horizontal)
        .padding(.bottom, 80) // Add padding to prevent button overlap
        .sheet(isPresented: $isPickerPresented) {
          ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) {
          if selectedImage != nil {
            showTextParserView = true
          }
        }
//        .fullScreenCover(isPresented: $showTextParserView, onDismiss: {
//          if alertMessage != "" {
//            showAlert = true
//          }
//        }) {
//          if let image = self.selectedImage {
////            TextParserView(
////              image: image,
////              viewModel: viewModel,
////              firebase: firebase,
////              isPresented: $showTextParserView,
////              note: note
////            ) { message in
////              alertMessage = message
////            }
////            var course = firebase.getCourse(note.courseID) {
////              courseResult in course = courseResult
////            }
//            TextParserViewNewNote(
//              image: image,
//              firebase: firebase,
//              isPresented: $showTextParserView,
//              course: course,
//              title: note.title,
//              note: $viewModel.note
//            ) { message in
//              alertMessage = message
//              showAlert = true
//              viewModel.loadImages()
//            }
//          }
//          else {
//            Text("Nil image")
//          }
//        }
        .fullScreenCover(isPresented: $showTextParserView, onDismiss: {
          if alertMessage != "" {
            showAlert = true
          }
        }) {
          if let image = self.selectedImage {
            TextParserView(
              images: [image],
              firebase: firebase,
              isPresented: $showTextParserView,
              course: course,
              title: note.title,
              note: $viewModel.note
            ) { message in
              alertMessage = message
              viewModel.loadImages()
            }
          }
          else {
            Text("Nil image")
          }
        }
        
        .alert(isPresented: $showAlert) {
          Alert(title: Text("Image Selection"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        
        // To avoid reloading images more than once
        .onAppear {
          if (!viewModel.imagesLoaded) {
            viewModel.loadImages()
          }
        }
      }
      
      // Review button outside ScrollView but inside ZStack
      NavigationLink(destination: QuizView(note: note, noteContent: note.content, firebase: firebase)) {
        HStack {
          Text("Review")
        }
        .font(.headline)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
      }
      .padding(.leading, 20)
      .padding(.bottom, 20)
    }
    .navigationTitle(note.title)
  }
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
  
}
