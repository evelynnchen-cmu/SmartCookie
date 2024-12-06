import SwiftUI

struct PDFParserView: View {
    var pdfText: String
    var firebase: Firebase
    @Binding var isPresented: Bool
    @State private var alertMessage = ""
    @State private var showAlert = false
    var course: Course?
    var title: String
    @Binding var note: Note?

    var body: some View {
        VStack {
            Text("Parsed PDF Content")
                .font(.title)
                .bold()
            
            ScrollView {
                Text(pdfText.isEmpty ? "No content found" : pdfText)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                handleSave()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleSave() {
        guard let course = course else {
            alertMessage = "Failed to get course"
            showAlert = true
            return
        }
        
        Task {
            await firebase.createNoteSimple(
                title: title,
                content: pdfText,
                images: [],
                courseID: course.id ?? "",
                folderID: nil,
                userID: course.userID
            ) { note in
                if let note = note {
                    self.note = note
                    isPresented = false
                } else {
                    alertMessage = "Failed to create note"
                    showAlert = true
                }
            }
        }
    }
}
