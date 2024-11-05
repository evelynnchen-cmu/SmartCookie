//
//  ImageView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 11/4/24.
//


//  ImageView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 11/4/24.
//

import SwiftUI

struct ImageView: View {
    var image: UIImage
    var onClose: () -> Void

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            Button("Close") {
                onClose()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
