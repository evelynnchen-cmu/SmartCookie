//
//  TextParseViewNewNote.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/14/24.
//

import SwiftUI

struct TextParserView: View {
  var images: [UIImage]
  var firebaseStorage: FirebaseStorage = FirebaseStorage()
  var firebase: Firebase
  @Binding var isPresented: Bool
  @Binding var course: Course?
  @Binding var note: Note?
  @State private var folder: Folder? = nil

  @State private var selectedImage: UIImage? = nil
  @State private var alertMessage = ""
  @State private var showAlert = false
  @State private var showExitConfirmation = false
  @State private var savePressed = false
  @State private var navigateToNoteView = false
  @State private var isChatViewPresented: Bool? = false //Bool optional so ChatView can handle non-sheet presentation
  @State private var title: String // Passed in init
  @State private var courseID: String = ""
  @State private var userID: String = ""
  @State private var content: String? = nil
  @State private var newNote: Note? = nil
  @State private var isParsing = true
  @State private var isEditing = false
  @State private var isSaving = false
  @State private var editedContent: String = ""
  @State private var keyboardHeight: CGFloat = 0
  @State private var showSaveForm = false
  private var openAI = OpenAI()
  @FocusState private var isTextEditorFocused: Bool
  public var tan = Color(hex: "775139")
  public var tan1 = Color(hex: "EBDBCE")
  public var lightBlue = Color(hex: "D8E9F5")
  public var mediumBlue = Color(hex: "89BBDE")
  public var darkBlue = Color(hex: "191D32")
  
  var completion: ((String) -> Void)?

  init(images: [UIImage], firebase: Firebase, isPresented: Binding<Bool>, course: Binding<Course?>, title: String, note: Binding<Note?>? = .constant(nil), completion: ((String) -> Void)? = nil) {
        self.images = images
        self.firebase = firebase
        self._isPresented = isPresented
        self._course = course
        self.title = title
        self._note = note ?? .constant(nil)
        self.completion = completion
    }
  
  var body: some View {
       GeometryReader { geometry in
           VStack(spacing: 0) {
               headerView
               contentArea
               
               if !isParsing && !isEditing {
                   bottomButtons
               }
           }
       }
       .background(tan1)
       .onAppear {
           parseImages()
           setupKeyboardObservers()
       }
       .onDisappear {
           removeKeyboardObservers()
       }
       .alert(isPresented: $showAlert) {
           Alert(title: Text("Image Upload"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
       }
       .alert(isPresented: $showExitConfirmation) {
           Alert(
               title: Text("Exit Confirmation"),
               message: Text("Are you sure you want to exit? Your data won't be saved."),
               primaryButton: .destructive(Text("Exit")) {
                   isPresented = false
               },
               secondaryButton: .cancel()
           )
       }
       .fullScreenCover(isPresented: Binding(
           get: { isChatViewPresented ?? false },
           set: { isChatViewPresented = $0 ? true : nil }
       )) {
           if let course = course {
                ChatView(selectedCourse: course, parsedText: content, isChatViewPresented: $isChatViewPresented)
           } else {
                ChatView(parsedText: content, isChatViewPresented: $isChatViewPresented)
           }
       }
       .overlay(
            Group {
              if self.isSaving {
                ZStack {
                  Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                  ProgressView("Updating/creating note...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(40)
                    .font(.headline)
                }
              }
            }
        )
       .sheet(isPresented: $showSaveForm) {
            AddNoteModalCourse(isPresented: $showSaveForm, firebase: firebase) { (title, course, folder) in
              if let courseObj = course {
                self.course = courseObj
              }
              self.title = title
              self.folder = folder
              isSaving = true
              handleSave()
              savePressed = true
            }
          }
        
   }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func handleSave() {
        firebaseStorage.uploadImagesToFirebase(images) { paths in
          // If imagePaths not nil, parse image
          if let imagePaths = paths {
            print("Image paths: \(imagePaths)")
            if let thisNote = self.note {
              Task {
                do {
                  try await updateNote(thisNote: thisNote, imagePaths: imagePaths)
                } catch {
                  print("Failed to update note")
                  alertMessage = "Failed to update note"
                  showAlert = true
                }
              }
            } else {
              if let course = course {
                courseID = course.id ?? ""
                userID = course.userID
                
                let noteTitle = title.isEmpty ? "\(imagePaths[0])" : title
                
                Task {
                  await firebase.createNoteSimple(
                    title: noteTitle,
                    content: content ?? "",
                    images: imagePaths,
                    courseID: courseID,
                    folderID: folder != nil ? folder?.id : nil,
                    userID: userID
                  ) { note in
                    if let note = note {
                      newNote = note
                      self.note = newNote
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
          } else {
            print("Failed to upload image")
            alertMessage = "Failed to upload image"
            showAlert = true
          }
        }
    }
    
    private func updateNote(thisNote: Note, imagePaths: [String]) async throws {
        // Update the note document in firebase with the new file paths
        firebase.updateNoteImages(note: thisNote, imagePaths: imagePaths) { updatedNote in
            if let updatedNote = updatedNote {
                self.note = updatedNote
                if let content = content {
                    let combinedContent = (thisNote.content) + "\n" + content
                    firebase.updateNoteContentCompletion(note: updatedNote, newContent: combinedContent) { updatedNote in
                        if let updatedNote = updatedNote {
                            self.note = updatedNote
                            Task {
                                var updatedSummary = combinedContent
                                do {
                                    updatedSummary = try await openAI.summarizeContent(content: combinedContent)
                                    print("new summary done")
                                } catch {
                                    alertMessage = "Failed to summarize content"
                                    showAlert = true
                                }
                                firebase.updateNoteSummary(note: updatedNote, newSummary: updatedSummary) { updatedNote in
                                    if let updatedNote = updatedNote {
                                        self.note = updatedNote
                                        completion?("\nNote updated successfully!")
                                        showAlert = false
                                        isPresented = false
                                    } else {
                                        print("Failed to update summary")
                                        alertMessage = "Failed to update summary"
                                        showAlert = true
                                    }
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
                print("Failed to update note with image paths")
                alertMessage = "Failed to update note with images"
                showAlert = true
            }
        }
    }

    private func parseImages() {
        var parsedTexts = [String](repeating: "", count: images.count)
        let dispatchGroup = DispatchGroup()

        for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            openAI.parseImage(image) { text in
                if let text = text {
                    parsedTexts[index] = text
                } else {
                    parsedTexts[index] = "Failed to parse image"
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.content = parsedTexts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            self.isParsing = false
        }
    }

    // Views
    private var headerView: some View {
        ZStack {
            Text("What we got")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Spacer()
                Button(action: {
                if !savePressed {
                    showExitConfirmation = true
                } else {
                    isPresented = false
                }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }
            }
        }
        .padding(.horizontal)
    }

    private var contentArea: some View {
        ZStack(alignment: .bottomTrailing) {
            if !isParsing {
                if let text = content {
                    if isEditing {
                        // Editable text area
                        TextEditor(text: $editedContent)
                            .focused($isTextEditorFocused)
                            .padding()
                    } else {
                        ScrollView {
                            Text(text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }
                } else {
                    Text("No text found")
                        .padding()
                }
                
                editingButtons
            } else {
                ProgressView("Parsing text...")
                    .padding()
            }
        }
        .frame(maxHeight: .infinity)
        .background(
            Group {
                if !isParsing {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(tan, lineWidth: 3)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
            }
        )
        .padding()
    }

    private var editingButtons: some View {
        VStack(spacing: 8) {
            if !isEditing {
                Button(action: {
                    self.content = nil
                    self.isParsing = true
                    parseImages()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .font(.system(size: 40))
                        .background(Color.white)
                        .foregroundColor(tan)
                }
                .padding(8)
                
                Button(action: {
                    editedContent = content ?? ""
                    isEditing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextEditorFocused = true
                    }
                }) {
                    Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(tan)
                }
                .padding(8)
            } else {
                Button(action: {
                    isTextEditorFocused = false
                    content = editedContent
                    isEditing = false
                }) {
                    Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(darkBrown)
                    
                }
                .padding(8)
            }
        }
        .padding(.trailing, 8)
        .padding(.bottom, 8)
    }

    private var bottomButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: {
                    isChatViewPresented = true
                }) {
                    Text("Chat Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tan, lineWidth: 1)
                        )
                }
                
                Button(action: {
                if note == nil {
                    showSaveForm = true
                } else {
                    isSaving = true
                    handleSave()
                    savePressed = true
                }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(tan)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}
