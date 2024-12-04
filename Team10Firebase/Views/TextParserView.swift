//
//  TextParseViewNewNote.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/14/24.
//

import SwiftUI

struct TextParserView: View {
    var images: [UIImage]?
    var parsedPDFText: String?
    var firebaseStorage: FirebaseStorage = FirebaseStorage()
    var firebase: Firebase
    @Binding var isPresented: Bool
    @State private var selectedImage: UIImage? = nil
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var navigateToNoteView = false
    @State private var isChatViewPresented: Bool? = false
    var course: Course?
    var title: String
    @Binding var note: Note?
    @State private var courseID: String = ""
    @State private var userID: String = ""
    @State private var content: String? = nil
    @State private var newNote: Note? = nil
    @State private var isParsing = true
    private var openAI = OpenAI()
    
    var completion: ((String) -> Void)?
    
    init(images: [UIImage]? = nil, parsedPDFText: String? = nil, firebase: Firebase, isPresented: Binding<Bool>, course: Course?, title: String, note: Binding<Note?>? = .constant(nil), completion: ((String) -> Void)? = nil) {
        self.images = images
        self.parsedPDFText = parsedPDFText
        self.firebase = firebase
        self._isPresented = isPresented
        self.course = course
        self.title = title
        self._note = note ?? .constant(nil) // Set to nil if not provided
        self.completion = completion
    }
    
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
                if !isParsing {
                    if let text = content {
                        if (text.isEmpty) {
                            Text("No text found")
                                .padding()
                        }
                        else {
                            Text(text)
                                .padding()
                        }
                    }
                    else {
                        Text("No text found")
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
                    if let text = content {
                        if let images = images, !images.isEmpty {
                            // Upload images and save with image paths
                            var uploadedPaths: [String] = []
                            let dispatchGroup = DispatchGroup()
                            
                            for image in images {
                                dispatchGroup.enter()
                                firebaseStorage.uploadImageToFirebase(image) { path in
                                    if let path = path {
                                        uploadedPaths.append(path)
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                            
                            // Wait for all uploads to finish
                            dispatchGroup.notify(queue: .main) {
                                handleSave(paths: uploadedPaths.isEmpty ? nil : uploadedPaths, text: text)
                            }
                        } else if let pdfText = parsedPDFText {
                            // Save PDF text only
                            handleSave(paths: nil, text: pdfText)
                        } else {
                            // Save text only
                            handleSave(paths: nil, text: text)
                        }
                    }
                    //                // Action to save the parsed text
                    //                if let images = images {
                    //                    firebaseStorage.uploadImagesToFirebase(images) { paths in
                    //                        if let imagePaths = paths {
                    //                            print("Image paths: \(imagePaths)")
                    //                            if let thisNote = self.note {
                    //                                Task {
                    //                                    do {
                    //                                        try await updateNote(thisNote: thisNote, imagePaths: imagePaths)
                    //                                    } catch {
                    //                                        print("Failed to update note")
                    //                                        alertMessage = "Failed to update note"
                    //                                        showAlert = true
                    //                                    }
                    //                                }
                    //                            }
                    //                            else {
                    //                                if let course = course {
                    //                                    //                        print("Course ID: \(course.id)")
                    //                                    courseID = course.id ?? ""
                    //                                    userID = course.userID
                    //
                    //                                    let noteTitle = title.isEmpty ? "\(imagePaths[0])" : title
                    //
                    //                                    Task {
                    //                                        await firebase.createNoteSimple(
                    //                                            title: noteTitle,
                    //                                            content: content ?? "",
                    //                                            images: imagePaths,
                    //                                            courseID: courseID,
                    //                                            folderID: nil,
                    //                                            userID: userID
                    //                                        ) { note in
                    //                                            if let note = note {
                    //                                                //                              print("Note created: \(note.id)")
                    //                                                newNote = note
                    //                                                self.note = newNote
                    //                                                completion?("\nNote \(newNote?.title ?? "Unknown Name") created successfully!")
                    //                                                showAlert = false
                    //                                                isPresented = false
                    //                                            } else {
                    //                                                print("Failed to create note")
                    //                                                alertMessage = "Failed to create note"
                    //                                                showAlert = true
                    //                                            }
                    //                                        }
                    //                                    }
                    //                                } else {
                    //                                    print("Failed to get course")
                    //                                    alertMessage = "Failed to get course"
                    //                                    showAlert = true
                    //                                }
                    //                            }
                    //
                    //                        }
                    //                        else {
                    //                            print("Failed to upload image")
                    //                            alertMessage = "Failed to upload image"
                    //                            showAlert = true
                    //                        }
                    //                    }
                    //                }
                }) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Action to re-extract the text
                    self.content = nil
                    self.isParsing = true
                    //                parseImages()
                    if let pdfText = parsedPDFText {
                        // Reuse the parsed PDF text
                        self.content = pdfText
                        self.isParsing = false
                    } else if let images = images, !images.isEmpty {
                        // Re-parse images if available
                        parseImages()
                    } else {
                        // No input to re-extract
                        self.content = "No input to re-extract"
                        self.isParsing = false
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
            //      parseImages()
            if let pdfText = parsedPDFText {
                self.content = pdfText
                self.isParsing = false
            } else if let images = images, !images.isEmpty {
                parseImages()
            } else {
                self.content = "No input provided"
                self.isParsing = false
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Image Upload"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: Binding(
            get: { isChatViewPresented ?? false },
            set: { isChatViewPresented = $0 ? true : nil }
        )) {
            if let course = course {
                ChatView(selectedCourse: course, isChatViewPresented: $isChatViewPresented)
            }
            else {
                Text("Failed to load course")
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
                                    }
                                    else {
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
        if let images = images {
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
                self.isParsing = false // Set parsing status to false
            }
        }
    }
    
    private func handleSave(paths: [String]?, text: String) {
        guard let course = course else {
            alertMessage = "Failed to get course"
            showAlert = true
            return
        }
        
        if let note = note {
            // Append to existing note
            Task {
                let updatedContent = (note.content + "\n" + text).trimmingCharacters(in: .whitespacesAndNewlines)
                firebase.updateNoteContentCompletion(note: note, newContent: updatedContent) { updatedNote in
                    if let updatedNote = updatedNote {
                        self.note = updatedNote
                        completion?("Note \(updatedNote.title) updated successfully!")
                        isPresented = false
                    } else {
                        alertMessage = "Failed to update note"
                        showAlert = true
                    }
                }
            }
        } else {
            // Create a new note
            Task {
                await firebase.createNoteSimple(
                    title: title,
                    content: text,
                    images: paths ?? [],
                    courseID: course.id ?? "",
                    folderID: nil,
                    userID: course.userID
                ) { note in
                    if let note = note {
                        self.note = note
                        completion?("Note \(note.title) created successfully!")
                        isPresented = false
                    } else {
                        alertMessage = "Failed to create note"
                        showAlert = true
                    }
                }
            }
        }
    }
}
