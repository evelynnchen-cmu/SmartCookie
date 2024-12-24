//
//  ScanView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct ScanView: View {
    @State private var capturedImages: [UIImage] = []
    @State private var showCamera = true
    @StateObject var firebase = Firebase()
    @State private var userID: String = ""
    @State private var showTextParserView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var courses: [Course] = []
    @State private var course: Course? = nil
    @State private var courseName = ""
    @State private var noteTitle = ""
    @State private var selectedTab = 0

    @Binding var selectedTabIndex: Int
    @Binding var navigateToCourse: Course?
    @Binding var navigateToNote: Note?
    @Binding var needToSave: Bool

    var body: some View {
      NavigationStack {
        ZStack {
          tan.edgesIgnoringSafeArea(.all)
          VStack {
            Text("Images Taken")
              .font(.title)
              .padding(.top)
            
            TabView(selection: $selectedTab) {
              // iPhone 11 image size: 3024.0 x 4032.0
             ForEach(capturedImages.indices, id: \.self) { index in
                Image(uiImage: capturedImages[index])
                  .resizable()
                  .scaledToFit()
                  .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) / 0.75)
                  .tag(index)
              }
              
              
              ZStack {
                Rectangle()
                  .fill(.white)
                  .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) / 0.75)
                  .overlay(
                    Rectangle()
                      .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                      .foregroundColor(darkBrown)
                  )
                  .onTapGesture {
                    showCamera = true
                  }
                VStack {
                  Image(systemName: "plus")
                    .font(.largeTitle)
                    .padding()
                  Text("Add new picture")
                    .font(.headline)
                }
                .foregroundColor(.black)
              }
              .tag(capturedImages.count)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxHeight: UIScreen.main.bounds.height - 300)
            .onAppear {
              setupPageControlAppearance()
            }
            
            if !capturedImages.isEmpty {
              Button("Extract All") {
                showTextParserView = true
              }
              .padding()
              .background(darkBrown)
              .foregroundColor(.white)
              .cornerRadius(8)
              .overlay(
                  RoundedRectangle(cornerRadius: 8)
                      .stroke(tan, lineWidth: 1)
              )
            }
          }
          .fullScreenCover(isPresented: $showCamera) {
            CameraContainerView { image in
              self.capturedImages.append(image)
              self.showCamera = false
              self.selectedTab = self.capturedImages.count - 1
            }
          }
          .fullScreenCover(isPresented: $showTextParserView) {
            TextParserView(
              images: self.capturedImages,
              firebase: firebase,
              isPresented: $showTextParserView,
              course: $course,
              title: noteTitle,
              note: $navigateToNote
            ) { message in
              self.capturedImages = []
              alertMessage = message
              showAlert = true
              self.selectedTabIndex = 0
              self.navigateToCourse = course
              self.navigateToNote = navigateToNote
              NotificationCenter.default.post(name: .resetHomeView, object: nil)
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
          .onReceive(NotificationCenter.default.publisher(for: .resetScanView)) { _ in
                capturedImages = []
                showCamera = true
                showTextParserView = false
                showAlert = false
                alertMessage = ""
                course = nil
                noteTitle = ""
                selectedTab = 0
            }
            .onChange(of: capturedImages) {
              if !capturedImages.isEmpty {
                needToSave = true
              }
            }
        }
      }
    }

    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(darkBrown)
      UIPageControl.appearance().pageIndicatorTintColor = UIColor(.white)
    }
}
