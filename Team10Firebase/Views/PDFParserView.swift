import SwiftUI

struct PDFParserView: View {
    var pdfText: String
    var firebase: Firebase
    var openAI: OpenAI = OpenAI()
    @Binding var isPresented: Bool
    @State private var alertMessage = ""
    @State private var showAlert = false
    var course: Course?
    var title: String
    @Binding var note: Note?
    @State private var isEditing = false
    @State private var editedContent: String = ""
    @FocusState private var isTextEditorFocused: Bool
    @State private var content: String? = nil
    @State private var isParsing = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showExitConfirmation = false
    @State private var savePressed = false
    @State private var isChatViewPresented: Bool? = false
    @State private var isSaving = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
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
                
                ZStack(alignment: .bottomTrailing) {
                    if !isParsing {
                        if isEditing {
                            ScrollView {
                                TextEditor(text: $editedContent)
                                    .focused($isTextEditorFocused)
                                    .frame(maxHeight: .infinity)
                                    .padding()
                                    .padding(.bottom, keyboardHeight)
                            }
                        } else {
                            ScrollView {
                                Text(content ?? pdfText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                        
                        VStack(spacing: 8) {
                            if !isEditing {
                                Button(action: {
                                    self.content = nil
                                    self.isParsing = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        self.content = pdfText
                                        self.isParsing = false
                                    }
                                }) {
                                    Image(systemName: "arrow.counterclockwise.circle")
                                        .font(.system(size: 40))
                                        .background(Color.white)
                                        .foregroundColor(darkBrown)
                                }
                                .padding(8)
                                
                                Button(action: {
                                    editedContent = content ?? pdfText
                                    isEditing = true
                                    isTextEditorFocused = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(darkBrown)
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
                    } else {
                        VStack {
                            Spacer()
                            ProgressView("Parsing PDF...")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(darkBrown, lineWidth: 3)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                )
                .padding()
                
                if !isParsing && !isEditing {
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
                                            .stroke(darkBrown, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                isSaving = true
                                savePressed = true
                                handleSave()
                            }) {
                                Text("Save")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(darkBrown)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(tan)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("PDF Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showExitConfirmation) {
            Alert(
                title: Text("Exit without saving?"),
                message: Text("Are you sure you want to exit without saving?"),
                primaryButton: .default(Text("Yes")) {
                    isPresented = false
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            content = pdfText
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .fullScreenCover(isPresented: Binding(
           get: { isChatViewPresented ?? false },
           set: { isChatViewPresented = $0 ? true : nil }
       )) {
//        .fullScreenCover(isPresented: $isChatViewPresented) {
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
                  ProgressView("Updating note...")
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
        guard let course = course else {
            alertMessage = "Failed to get course"
            showAlert = true
            return
        }

        guard let note = note else {
            alertMessage = "Failed to get note"
            showAlert = true
            return
        }

        let updatedContent = (note.content + "\n\n" + (content ?? pdfText)).trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            firebase.updateNoteContentCompletion(note: note, newContent: updatedContent) { updatedNote in
                if let updatedNote = updatedNote {
                    self.note = updatedNote
                    isPresented = false
                } else {
                    alertMessage = "Failed to update note"
                    showAlert = true
                }
            }
        }
        Task {
            if let updatedNote = self.note {
                var updatedSummary = updatedNote.summary
                do {
                    updatedSummary = try await openAI.summarizeContent(content: updatedContent)
                } catch {
                    alertMessage = "Failed to summarize content"
                    showAlert = true
                }
                firebase.updateNoteSummary(note: updatedNote, newSummary: updatedSummary) { updatedNote in
                    if let updatedNote = updatedNote {
                        self.note = updatedNote
                        showAlert = false
                    } else {
                        print("Failed to update summary")
                        alertMessage = "Failed to update summary"
                        showAlert = true
                    }
                }
            }
        }
    }
}
