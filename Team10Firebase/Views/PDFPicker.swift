//
//  PDFPicker.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 12/2/24.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFPicker: UIViewControllerRepresentable {
    var completion: (String?) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completion: (String?) -> Void
        
        init(completion: @escaping (String?) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                print("No URL returned")
                completion(nil)
                return
            }
            
            print("Picked document URL: \(url)")
            
            extractText(from: url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
            completion(nil)
        }
        
        private func extractText(from url: URL) {
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security scoped resource")
                completion(nil)
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            let decodedPath = url.absoluteString.removingPercentEncoding ?? url.absoluteString
            let decodedURL = URL(string: decodedPath)

            guard let decodedURL = decodedURL else {
                print("Failed to decode URL")
                completion(nil)
                return
            }

            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(decodedURL.lastPathComponent)
            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: url, to: tempURL)
            } catch {
                print("Failed to copy file to temporary location: \(error)")
                completion(nil)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                guard let pdfDocument = PDFDocument(url: tempURL) else {
                    print("Failed to create PDFDocument from temporary file")
                    DispatchQueue.main.async {
                        self.completion(nil)
                    }
                    return
                }

                var extractedText = ""
                for pageIndex in 0..<pdfDocument.pageCount {
                    if let page = pdfDocument.page(at: pageIndex), let pageContent = page.string {
                        extractedText += pageContent
                    }
                }

                DispatchQueue.main.async {
                    if extractedText.isEmpty {
                        print("Extracted text is empty")
                        self.completion(nil)
                    } else {
                        print("Successfully extracted text")
                        self.completion(extractedText)
                    }
                }
            }
        }
    }
}
