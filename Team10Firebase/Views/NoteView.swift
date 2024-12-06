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
    @State private var isFilePickerPresented = false
    @State private var selectedNoteForAppend: Note?

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
                contentSection
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // Prevent button overlap
            .modifier(SupportingModifiers())
            .onAppear {
                print("All Folders: \(firebase.folders.map { ($0.folderName, $0.courseID) })")
                print("All Notes: \(firebase.notes.map { ($0.title, $0.courseID, $0.fileLocation) })")
            }
            reviewButton
        }
        .navigationTitle(note.title)
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
          if let note = viewModel.note {
            SummaryComponent(summary: note.summary, title: "Summary")
            
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
}
