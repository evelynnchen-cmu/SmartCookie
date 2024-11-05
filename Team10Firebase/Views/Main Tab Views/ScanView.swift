//  ScanView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct ScanView: View {
    @State private var capturedImage: UIImage?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack {
                if let image = capturedImage {
                    // Display captured image
                    ImageView(image: image) {
                        // Reset captured image to re-open the camera
                        self.capturedImage = nil
                    }
                    .frame(width: 300, height: 300)
                    .padding()
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
