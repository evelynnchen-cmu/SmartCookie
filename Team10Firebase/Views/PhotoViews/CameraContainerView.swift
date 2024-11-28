//  CameraContainerView.swift
//  Team10Firebase

// This view wraps the camera interface and manages the photo capture workflow.
// It displays a full-screen live camera view with a "Take Picture" button overlay.
// When the user takes a photo, the captured image is passed to the `onPhotoCaptured` closure, which allows
// `ScanView` to handle the image and display it after capturing.

import SwiftUI

struct CameraContainerView: View {
    var onPhotoCaptured: (UIImage) -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        CameraViewController(onPhotoCaptured: { image in
            self.onPhotoCaptured(image)
            self.presentationMode.wrappedValue.dismiss()
        })
        .edgesIgnoringSafeArea(.all)
    }
    // var body: some View {
    //     ZStack {
    //         CameraView(onPhotoCaptured: onPhotoCaptured)
    //             .edgesIgnoringSafeArea(.all)

    //         VStack {
    //             Spacer()
    //             Button(action: {
    //                 NotificationCenter.default.post(name: .takePicture, object: nil)
    //             }) {
    //                 Text("Take Picture")
    //                     .padding()
    //                     .background(Color.blue)
    //                     .foregroundColor(.white)
    //                     .cornerRadius(8)
    //             }
    //             .padding(.bottom, 30)
    //         }
    //     }
    // }
}
