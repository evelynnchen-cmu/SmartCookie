import SwiftUI

struct SummaryComponent: View {
    var summary: String
    var title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            Text(summary)
            .font(.body) // Smaller font for the summary text
        }
        .padding(16) // Padding around the box
        .background(
            RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.2)) // Background color for the box
        )
        .frame(maxWidth: .infinity)
    }
}
