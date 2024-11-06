//  CameraContainerView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 11/4/24.
//

import SwiftUI

struct CameraContainerView: View {
    @State private var capturedImage: UIImage?
    var onPhotoCaptured: (UIImage) -> Void

    var body: some View {
        ZStack {
            // Show live camera view
            CameraView { image in
                self.capturedImage = image
                onPhotoCaptured(image)
            }
            .edgesIgnoringSafeArea(.all) // Ensure camera fills the screen

            // Overlay the "Take Picture" button
            VStack {
                Spacer()
                Button(action: {
                    NotificationCenter.default.post(name: .takePicture, object: nil)
                }) {
                    Text("Take Picture")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 30)
            }
        }
    }
}
