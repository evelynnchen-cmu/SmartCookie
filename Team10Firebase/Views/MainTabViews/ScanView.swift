//  ScanView.swift
//  Team10Firebase

import SwiftUI

struct ScanView: View {
    // @State var capturedImage: UIImage?
    @State private var capturedImages: [UIImage] = []
    @State private var showCamera = true
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
    @State private var selectedTab = 0

    var body: some View {
      NavigationStack {
        ZStack {
          Color.blue.opacity(0.2).edgesIgnoringSafeArea(.all) // Background color for the entire view
          VStack {
            Text("Scan Results")
              .font(.title)
              .padding(.top)
            
            TabView(selection: $selectedTab) {
              // iPhone 11 image size: 3024.0 x 4032.0
              ForEach(capturedImages.indices, id: \.self) { index in
                Image(uiImage: capturedImages[index])
                  .resizable()
                  .scaledToFit()
                  .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) / 0.75)
                //                          .padding()
                  .tag(index) // Tag each image with its index
              }
              
              
              ZStack {
                Rectangle()
                  .fill(Color.gray.opacity(0.5))
                  .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) / 0.75)
                  .overlay(
                    //                                RoundedRectangle(cornerRadius: 10)
                    Rectangle()
                      .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                      .foregroundColor(.black)
                  )
                  .onTapGesture {
                    showCamera = true
                  }
                VStack {
                  Image(systemName: "plus")
                    .font(.largeTitle)
                  Text("Add new Picture")
                    .font(.headline)
                }
                .foregroundColor(.white)
              }
              .tag(capturedImages.count)
            }
            //                .background(Color.blue.opacity(0.2))
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxHeight: UIScreen.main.bounds.height - 300)
            .onAppear {
              setupPageControlAppearance()
            }
            
            if !capturedImages.isEmpty {
              Button("Extract All") {
                showSaveForm = true
              }
              .padding()
              // .background(Color.green)
              // .background(Color.gray.opacity(0.2))
              .background(.white)
              // .foregroundColor(.white)
              .foregroundColor(.black)
              .cornerRadius(8)
            }
          }
          //            }
          //            .background(Color.blue.opacity(0.2))
          .fullScreenCover(isPresented: $showCamera) {
            CameraContainerView { image in
              self.capturedImages.append(image)
              self.showCamera = false
              self.selectedTab = self.capturedImages.count - 1
            }
          }
          .fullScreenCover(isPresented: $showTextParserView) {
            if let course = course {
              TextParserView(
                image: self.capturedImages[0],
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
          .sheet(isPresented: $showSaveForm) {
            AddNoteModalCourse(isPresented: $showSaveForm, firebase: firebase) { (title, course) in
              if let courseObj = course {
                self.course = courseObj
              }
              self.noteTitle = title
            }
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

    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .blue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.blue.withAlphaComponent(0.2)
    }
}

#Preview {
    ScanView()
}
