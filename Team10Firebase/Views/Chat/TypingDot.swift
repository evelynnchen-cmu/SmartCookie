//
//  TypingDot.swift
//  Team10Firebase
//
//  Created by Evelynn Chen on 11/10/24.
//

import Foundation
import SwiftUI

struct TypingDot: View {
    let delay: Double
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 7, height: 7)
            .scaleEffect(scale)
            .animation(
                Animation
                    .easeInOut(duration: 0.6)
                    .repeatForever()
                    .delay(delay),
                value: scale
            )
            .onAppear {
                scale = 0.3
            }
    }
}

struct TypingIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            TypingDot(delay: 0.0)
            TypingDot(delay: 0.2)
            TypingDot(delay: 0.4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(BubbleShape(isUser: false))
    }
}
