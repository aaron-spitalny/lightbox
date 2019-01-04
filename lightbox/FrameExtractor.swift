//
//  FrameExtractor.swift
//  lightbox
//
//  Created by Aaron Spitalny on 12/5/18.
//  Copyright © 2018 Aaron Spitalny. All rights reserved.
//

import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage, flag: Bool)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var permissionGranted = false
    private let context = CIContext()
    private var uiImage = UIImage()
    weak var delegate: FrameExtractorDelegate?

    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.high

    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
            break
        case .notDetermined:
            requestPermission()
            break
        default:
            permissionGranted = false
            break
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func toggleCaptureSession(){
        if  captureSession.isRunning {
            captureSession.stopRunning()
            self.delegate?.captured(image: OpenCVWrapper.getGrabCut(self.uiImage)!, flag: true)
        } else {
            captureSession.startRunning()
        }
        
    }
   
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        self.uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer)!
        DispatchQueue.main.async { [unowned self] in
            if self.captureSession.isRunning{
                self.delegate?.captured(image: self.uiImage, flag: false)
            }
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(for: .video)
    }
}
