//
//  ScannerViewModel.swift
//  LionReading
//
//  Created by TanJianing.
//  Part of this file is difficult to verify due to economic problems

import AVFoundation
import SwiftUI

class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    @Published var isScanning = false
    @Published var error: String?
    
    var captureSession: AVCaptureSession?
    
    func setupCamera() {
        print("Start setting up the camera - Try accessing the Mac camera")
        // Reset status
        self.scannedCode = nil
        self.error = nil
        
        #if targetEnvironment(simulator)
        // In the simulator, use the simulation function directly
        self.isScanning = true
        #else
        // On a real machine, check camera permissions
        checkCameraPermission()
        #endif
    }
    
    // An analog scanning method added for the simulator environment
        #if targetEnvironment(simulator)
        func simulateScan(with code: String = "9782760151420") {
            // Delay 1.5 seconds to simulate the real scanning process
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("Simulated scan success：\(code)")
                AudioServicesPlaySystemSound(1519) // Use the system prompt tone
                self.scannedCode = code
                self.isScanning = false
            }
        }
        #endif
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            print("You have obtained camera permissions")
            self.initializeCaptureSession()
        case .notDetermined:
            print("Camera permissions not determined, request permissions")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("The user granted permission to the camera")
                        self.initializeCaptureSession()
                    } else {
                        print("The user denied camera permission")
                        self.error = "Camera permissions are required to scan ISBNs"
                    }
                }
            }
        case .denied, .restricted:
            print("Camera permissions are denied or limited")
            self.error = "Allow access to the camera in Settings"
        @unknown default:
            print("Unknown camera permission status")
            self.error = "Unknown camera authorization status"
        }
    }
    
    private func initializeCaptureSession() {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        // List all available camera devices
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera,
            .builtInTrueDepthCamera,
            .builtInUltraWideCamera
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        
        print("Number of available devices: \(discoverySession.devices.count)")
        for (index, device) in discoverySession.devices.enumerated() {
            print("Device \(index): \(device.localizedName)")
        }
        
        // Attempt to acquire device
        var videoCaptureDevice: AVCaptureDevice?
        
        #if targetEnvironment(simulator)
            // Simulation of scanning results in a simulator environment
            func simulateScan(with code: String = "9782760151420") {
                self.scannedCode = code
                self.stopScanning()
                print("Simulated scan result: \(code)")
            }
        #endif

        
        // Try using the default camera
        if videoCaptureDevice == nil {
            videoCaptureDevice = AVCaptureDevice.default(for: .video)
            if let device = videoCaptureDevice {
                print("Use default camera: \(device.localizedName)")
            }
        }
        
        guard let videoDevice = videoCaptureDevice else {
            self.error = "No usable cameras found"
            print("The camera device could not be obtained")
            return
        }
        
        // Create input
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Failed to initialize the camera：\(error.localizedDescription)")
            self.error = "Failed to initialize the camera: \(error.localizedDescription)"
            return
        }
       
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            print("Video input has been added to the capture session")
        } else {
            self.error = "Your device does not support scanning"
            print("Unable to add video input to capture session")
            return
        }
        
        // Create metadata output for barcode scanning
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // Set the proxy on the home queue
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set the type to detect - EAN13 is the format used by ISBNs
            metadataOutput.metadataObjectTypes = [.ean13]
            print("Metadata output is set up to scan the EAN13 barcode")
        } else {
            self.error = "Your device does not support barcode scanning"
            print("Unable to add metadata output to capture session")
            return
        }
        
        // Start a session in the background to prevent UI freezing
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
            print("The capture session is running")
            DispatchQueue.main.async {
                self.isScanning = true
            }
        }
    }
    
    func stopScanning() {
        #if targetEnvironment(simulator)
        isScanning = false
        #else
        captureSession?.stopRunning()
        isScanning = false
        #endif
    }
    
    // The agent method processes the scanned code
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Playback feedback sound
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Update UI to display scanned codes
            self.scannedCode = stringValue
            self.stopScanning()
        }
    }
}
