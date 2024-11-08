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
    @State private var capturedImage: UIImage?
    @State private var showCamera = false

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
                }
            }
        }
    }
}

#Preview {
    ScanView()
}
