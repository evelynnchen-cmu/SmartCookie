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
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isActionSheetPresented = false
    @State private var showGalleryView = false
    var note: Note
    var course: Course
    
    init(firebase: Firebase, note: Note, course: Course) {
        self.firebase = firebase
        _viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
        self.note = note
        self.course = course
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text(note.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    recentNoteSummarySection

                    Text(note.content)
                        .padding()
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: QuizView(note: note, noteContent: note.content, firebase: firebase)) {
                        Text("Practice")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(darkBrown)
                            .cornerRadius(12)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        isActionSheetPresented = true
                    }) {
                        Image(systemName: "document.badge.arrow.up")
                            .foregroundColor(darkBrown)
                            .imageScale(.large)
                            .frame(height: 44)
                    }
                    
                    Button(action: {
                        showGalleryView = true
                    }) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .foregroundColor(darkBrown)
                            .imageScale(.large)
                            .frame(height: 44)
                    }
                }
            }
        }
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
                if let text = extractedText {
                    selectedPDFText = text
                    DispatchQueue.main.async {
                        showPDFParserView = true
                    }
                } else {
                    alertMessage = "Failed to extract text from PDF"
                    showAlert = true
                }
            }
        }
        .sheet(isPresented: $showGalleryView) {
            NavigationView {
                VStack {
                    if !viewModel.images.isEmpty {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                        .shadow(radius: 2)
                                }
                            }
                            .padding()
                        }
                    } else {
                        Text("No images available")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("Original Image(s)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showGalleryView = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                    }
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
        .onAppear {
            if !viewModel.imagesLoaded {
                viewModel.loadImages()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var recentNoteSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Get caught up!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        Text(note.summary)
                            .padding()
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 5)
                    
                    LinearGradient(
                        gradient: Gradient(colors: [.white.opacity(0), .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(darkBrown, lineWidth: 2)
                )
                
                Text("Summary from \(dateFormatter.string(from: note.createdAt))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
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
