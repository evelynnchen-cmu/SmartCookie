//
//  ScanView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct ScanView: View {
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack {
            Text("Scan")
                .font(.largeTitle)
                .padding()

            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding()
            } else {
                Text("No image captured")
                    .foregroundColor(.gray)
                    .padding()
            }

            Button(action: {
                print("Open Camera button tapped")
                showImagePicker = true
            }) {
                Text("Open Camera")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $capturedImage, sourceType: .camera)
        }
        .onChange(of: capturedImage) { newImage in
            if newImage != nil {
                print("Image captured successfully")
            } else {
                print("No image captured or operation canceled")
            }
        }
    }
}

#Preview {
    ScanView()
}
