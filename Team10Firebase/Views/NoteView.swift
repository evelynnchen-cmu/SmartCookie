//
//  NoteView.swift
//  Team10Firebase
//
//  Created by Emma Tong on 10/30/24.
//

import SwiftUI

struct NoteView: View {
    var note: Note

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Note ID: \(note.id)")
                        .font(.body)
                    Text("userID: \(note.userID)")
                        .font(.body)
                    Text(note.title)
                        .font(.body)
                    Text(note.summary)
                        .font(.body)
                    Text(note.content)
                        .font(.body)
                    Text("images: \(note.images)")
                        .font(.body)
                    Text("createdAt: \(note.createdAt)")
                        .font(.body)
                    Text("courseID: \(note.courseID)")
                        .font(.body)
                    Text("fileLocation: \(note.fileLocation)")
                        .font(.body)
                    Text("lastAccessed: \(note.lastAccessed)")
                        .font(.body)
                }
                .padding(.leading)
            }
        }
    }
}

//#Preview {
//    NoteView()
//}
