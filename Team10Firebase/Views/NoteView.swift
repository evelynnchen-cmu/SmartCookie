import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import PhotosUI

struct NoteView: View {
    @StateObject var viewModel: NoteViewModel
    @ObservedObject var firebase: Firebase
    @State private var isPickerPresented = false
    @State private var isPDFPickerPresented = false
    @State private var showTextParserView = false
    @State private var selectedImage: UIImage?
    @State private var selectedPDFText: String?
    @State private var contentTab = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isFilePickerPresented = false
    @State private var selectedNoteForAppend: Note?

    var note: Note
    var course: Course

    init(firebase: Firebase, note: Note, course: Course) {
        self.firebase = firebase
        _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
        self.note = note
        self.course = course
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView {
                contentSection
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // Prevent button overlap
            .modifier(SupportingModifiers())
            .onAppear {
                print("All Folders: \(firebase.folders.map { ($0.folderName, $0.courseID) })")
                print("All Notes: \(firebase.notes.map { ($0.title, $0.courseID, $0.fileLocation) })")
            }
            reviewButton
        }
        .navigationTitle(note.title)
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            summaryView
            photoUploadButton
            pdfUploadButton
            tabSwitcher
            tabContent
        }
    }

    // MARK: - Summary View
    private var summaryView: some View {
        VStack(spacing: 8) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(.primary)
            Text(viewModel.note?.summary ?? "No summary available")
                .font(.body)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
        .frame(maxWidth: .infinity)
    }

    // MARK: - Buttons
    private var photoUploadButton: some View {
        Button(action: { isPickerPresented = true }) {
            buttonText("Upload Image from Photo Library")
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _ in
            showTextParserView = true
        }
    }

    private var pdfUploadButton: some View {
        Button(action: { isPDFPickerPresented = true }) {
            buttonText("Upload and Parse PDF")
        }
        .sheet(isPresented: $isPDFPickerPresented) {
            PDFPicker { extractedText in
                if let text = extractedText {
                    selectedPDFText = text
                    isFilePickerPresented = true
                } else {
                    alertMessage = "Failed to extract text from PDF."
                    showAlert = true
                }
            }
        }
        .sheet(isPresented: $isFilePickerPresented) {
            FilePickerView(firebase: firebase, isPresented: $isFilePickerPresented, selectedNote: $selectedNoteForAppend)
        }
        .fullScreenCover(isPresented: $showTextParserView) {
            if let pdfText = selectedPDFText {
                parserView(parsedPDFText: pdfText)
            } else if let image = selectedImage {
                parserView(images: [image])
            }
        }
    }

    private func buttonText(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }

    // MARK: - Tab Switcher
    private var tabSwitcher: some View {
        HStack {
            Button(action: { contentTab = true }) {
                tabButtonText("Content", isSelected: contentTab)
            }
            Button(action: { contentTab = false }) {
                tabButtonText("Images", isSelected: !contentTab)
            }
        }
    }

    private func tabButtonText(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .blue)
            .cornerRadius(8)
    }

    // MARK: - Tab Content
    private var tabContent: some View {
        Group {
            if contentTab {
                contentTabView
            } else {
                imageTabView
            }
        }
    }

    private var contentTabView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let selectedPDFText = selectedPDFText {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parsed PDF Content:")
                        .font(.headline)
                    Text(selectedPDFText)
                        .font(.body)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
            } else {
                Text(note.content)
                    .font(.body)
            }
            metadataView
        }
    }

    private var metadataView: some View {
        Group {
            Text("Created At: \(note.createdAt, formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
            Text("Last Accessed: \(note.lastAccessed ?? Date(), formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var imageTabView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else if viewModel.images.isEmpty {
                Text("No images available")
            } else {
                VStack {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
        }
    }

    // MARK: - Review Button
    private var reviewButton: some View {
        NavigationLink(destination: QuizView(note: note, noteContent: note.content, firebase: firebase)) {
            HStack { Text("Review") }
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding(.leading, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Helper
    private func parserView(parsedPDFText: String? = nil, images: [UIImage]? = nil) -> some View {
        TextParserView(
            images: images,
            parsedPDFText: parsedPDFText,
            firebase: firebase,
            isPresented: $showTextParserView,
            course: course,
            title: note.title,
            note: bindingForSelectedNote()
        ) { message in
            alertMessage = message
            viewModel.loadImages()
        }
    }
    
    // Helper function to return the correct Binding<Note?>
    private func bindingForSelectedNote() -> Binding<Note?> {
        if let selectedNote = selectedNoteForAppend {
            return .constant(selectedNote) // Wrap selectedNoteForAppend in a constant Binding
        }
        return $viewModel.note // Use the viewModel's note binding otherwise
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct SupportingModifiers: ViewModifier {
    func body(content: Content) -> some View {
        content
            .alert(isPresented: .constant(false)) {
                Alert(title: Text("Error"), message: Text("An error occurred"), dismissButton: .default(Text("OK")))
            }
    }
}
