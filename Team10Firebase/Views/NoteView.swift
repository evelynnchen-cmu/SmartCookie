
import SwiftUI

struct NoteView: View {
    var note: Note

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Note ID: \(note.id ?? "N/A")")
                    .font(.body)
                Text("User ID: \(note.userID ?? "N/A")")
                    .font(.body)
                Text("Title: \(note.title)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Summary: \(note.summary)")
                    .font(.body)
                    .foregroundColor(.gray)
                Text("Content: \(note.content)")
                    .font(.body)
                Text("Images: \(note.images.isEmpty ? "No images" : "\(note.images.count) image(s)")")
                    .font(.body)
                Text("Created At: \(note.createdAt, formatter: dateFormatter)")
                    .font(.body)
                Text("Course ID: \(note.courseID ?? "N/A")")
                    .font(.body)
                Text("File Location: \(note.fileLocation)")
                    .font(.body)
                Text("Last Accessed: \(note.lastAccessed ?? Date(), formatter: dateFormatter)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.leading)
        }
        .navigationTitle(note.title)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

