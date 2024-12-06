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
              .font(.body)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue.opacity(0.2))
        )
        .frame(maxWidth: .infinity)
    }
}
