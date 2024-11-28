//  ScanView.swift
//  Team10Firebase

//  This view serves as the main scanning interface for the user. It allows the user to:
//  1. Open the camera view by tapping the "Open Camera" button.
//  2. Display the captured image once the user takes a picture.
//  3. Provide "Close" and "Parse" buttons for further actions:
//     - "Close" will reset the captured image and re-enable the camera.
//     - "Parse" will handle the logic for processing the image.
//  This view uses a `CameraContainerView` to handle camera interactions and photo capturing.


import SwiftUI

struct ScanView: View {
    @State var capturedImage: UIImage?
    @State private var showCamera = false
//  TODO: Refactor so scanview and noteview use same fb object
    @StateObject var firebase = Firebase()
    @State private var userID: String = ""
    @State private var showTextParserView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var courses: [Course] = []
    @State private var course: Course? = nil
    @State private var showSaveForm = false
    @State private var courseName = ""
    @State private var noteTitle = ""

    var body: some View {
        NavigationStack {
            VStack {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding()
                    
                    HStack {
                        Button("Close") {
                            capturedImage = nil
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Parse") {
                            print("Parsing image...")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    Text("No image captured")
                        .foregroundColor(.gray)
                        .padding()
                }

                Button(action: {
                    showCamera = true
                }) {
                    Text("Open Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraContainerView { image in
                    self.capturedImage = image
                    self.showCamera = false
                    self.showSaveForm = true
                }
            }
            .fullScreenCover(isPresented: $showTextParserView) {
              if let image = self.capturedImage {
                if let course = course {
                  TextParserView(
                    image: image,
                    firebase: firebase,
                    isPresented: $showTextParserView,
                    course: course,
                    title: noteTitle
                  ) { message in
                    alertMessage = message
                    showAlert = true
                  }
                }
                else {
                  Text("Nil course")
                }
              }
              else {
                Text("Nil image")
              }
            }
//            .sheet(isPresented: $showSaveForm, onDismiss: {
//              print("dismissed")
//              if course != nil {
//                  showTextParserView = true
//                print("sheet presented")
//              }
//              else {
//                print("sad")
//              }
//            }) {
//              AddNoteModalCourse(isPresented: $showSaveForm, firebase: firebase) { course in
//                if let courseObj = course {
//                  self.course = courseObj
//                }
//              }
            .sheet(isPresented: $showSaveForm) {
              AddNoteModalCourse(isPresented: $showSaveForm, firebase: firebase) { (title, course) in
                if let courseObj = course {
                  self.course = courseObj
                }
                self.noteTitle = title
              }
            //   .onDisappear {
            //     print("dismissed")
            //     if course != nil {
            //         showTextParserView = true
            //       print("sheet presented")
            //     }
            //     else {
            //       print("sad")
            //     }
            //   }
          }
            .onChange(of: showSaveForm) {
               print("showSaveForm changed")
              if course != nil {
                  showTextParserView = true
              }
            }
            .onAppear() {
              firebase.getCourses()
              courses = firebase.courses
              firebase.getUsers()
              firebase.getFirstUser { user in
                  if let user = user {
                    userID = user.id ?? ""
                  } else {
                      alertMessage = "Failed to fetch user."
                  }
              }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Camera Scan"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ScanView()
}
