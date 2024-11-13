
import SwiftUI
import PhotosUI

struct NoteView: View {
  @StateObject var viewModel: NoteViewModel
  @ObservedObject var firebase: Firebase
  @State private var isPickerPresented = false
  @State private var showTextParserView = false
  @State private var selectedImage: UIImage?
  @State private var contentTab = true
  @State private var showAlert = false
  @State private var alertMessage = ""
  var note: Note
  
  
  init(firebase: Firebase, note: Note) {
    self.firebase = firebase
    _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
    self.note = note
  }
  
  var body: some View {
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
            image: image,
            viewModel: viewModel,
            firebase: firebase,
            isPresented: $showTextParserView,
            note: note
          ) { message in
              alertMessage = message
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
      .navigationTitle(note.title)
    }
  }
  
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
