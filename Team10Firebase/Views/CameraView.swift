//  CameraView.swift
//  Team10Firebase
//
//  Created by Alanna Cao on 11/2/24.
//

import SwiftUI
import AVFoundation
import Foundation

struct CameraView: UIViewRepresentable {
    var onPhotoCaptured: (UIImage) -> Void

    func makeUIView(context: Context) -> CameraUIView {
        let cameraUIView = CameraUIView()
        cameraUIView.onPhotoCaptured = onPhotoCaptured
        return cameraUIView
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {
        // No updates needed here
    }
}

class CameraUIView: UIView, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    var onPhotoCaptured: ((UIImage) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(takePicture), name: .takePicture, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        photoOutput = AVCapturePhotoOutput()

        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)

        // Configure the preview layer to display the camera feed
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)

        // Start the capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            // Ensure the capture session runs on the main thread for UI updates
            DispatchQueue.main.async {
                self.setNeedsLayout() // Mark the view for layout updates
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the preview layer's frame is updated to match the view's bounds
        if let previewLayer = layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = bounds
        }
    }

    @objc func takePicture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        onPhotoCaptured?(image)
    }
}


extension Foundation.Notification.Name {
  static let takePicture = Foundation.Notification.Name("takePicture")
}
