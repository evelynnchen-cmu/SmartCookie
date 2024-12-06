import SwiftUI
import PhotosUI

struct NoteView: View {
    @StateObject var viewModel: NoteViewModel
    @ObservedObject var firebase: Firebase
    @State private var isPickerPresented = false
    @State private var isPDFPickerPresented = false
    @State private var showTextParserView = false
    @State private var showPDFParserView = false
    @State private var selectedImage: UIImage?
    @State private var selectedPDFText: String?
    @State private var contentTab = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isActionSheetPresented = false
    var note: Note
    var course: Course
    
    init(firebase: Firebase, note: Note, course: Course) {
        self.firebase = firebase
        _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
        self.note = note
        self.course = course
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let note = viewModel.note {
                        SummaryComponent(summary: note.summary, title: "Summary")
                        
                        Spacer()
                        
                        // Buttons to switch between tabs
                        tabSwitcher
                        
                        if contentTab {
                            contentTabView
                        } else {
                            imageTabView
                        }
                    } else {
                        Text("Loading note...")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Prevent button overlap
                .sheet(isPresented: $isPickerPresented) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                }
                .onChange(of: selectedImage) {
                    if selectedImage != nil {
                        showTextParserView = true
                    }
                }
                .sheet(isPresented: $isPDFPickerPresented) {
                    PDFPicker { extractedText in
                        print("Extracted text: \(extractedText ?? "No text extracted")")
                        if let text = extractedText {
                            selectedPDFText = text
                            print("selectedPDFText updated: \(selectedPDFText ?? "Nil")") // Debugging
                            DispatchQueue.main.async {
                                showPDFParserView = true // Delay until text is set
                            }
                        } else {
                            alertMessage = "Failed to extract text from PDF"
                            showAlert = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $showTextParserView, onDismiss: handleTextParserDismiss) {
                    if let image = self.selectedImage {
                        TextParserView(
                            images: [image],
                            firebase: firebase,
                            isPresented: $showTextParserView,
                            course: course,
                            title: note.title,
                            note: $viewModel.note
                        ) { message in
                            alertMessage = message
                            viewModel.loadImages()
                        }
                    } else {
                        Text("Nil image")
                    }
                }
                .fullScreenCover(isPresented: Binding(
                    get: { showPDFParserView && selectedPDFText != nil },
                    set: { showPDFParserView = $0 }
                ), onDismiss: handlePDFParserDismiss) {
                    PDFParserView(
                        pdfText: selectedPDFText ?? "No PDF text available",
                        firebase: firebase,
                        isPresented: $showPDFParserView,
                        course: course,
                        title: note.title,
                        note: $viewModel.note
                    )
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onAppear {
                    if !viewModel.imagesLoaded {
                        viewModel.loadImages()
                    }
                }
            }
            
            // Floating plus button
            Button(action: {
                isActionSheetPresented = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(
                    title: Text("Upload Options"),
                    message: Text("Select an option"),
                    buttons: [
                        .default(Text("Upload Image")) {
                            isPickerPresented = true
                        },
                        .default(Text("Upload PDF")) {
                            isPDFPickerPresented = true
                        },
                        .cancel()
                    ]
                )
            }
        }
        .navigationTitle(note.title)
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
    
    // MARK: - Content Tab View
    private var contentTabView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.content)
                .font(.body)
            Text("Created At: \(note.createdAt, formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
            Text("Last Accessed: \(note.lastAccessed ?? Date(), formatter: dateFormatter)")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Image Tab View
    private var imageTabView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
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
    
    private func handleTextParserDismiss() {
        if alertMessage != "" {
            showAlert = true
        }
    }
    
    private func handlePDFParserDismiss() {
        if alertMessage != "" {
            showAlert = true
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
