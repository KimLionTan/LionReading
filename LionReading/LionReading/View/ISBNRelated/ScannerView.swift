//
//  ScannerView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode
   
    @State private var navigateToISBNInput = false
    @State private var scannedISBN: String = ""
    
     var body: some View {
         ZStack {
             Background()
             
             VStack {
                 ZStack {
                     #if targetEnvironment(simulator)
                     VStack {
                         Image(systemName: "barcode.viewfinder")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 150, height: 150)
                             .foregroundColor(.gray)
                         
                         Text("Camera Preview (Simulator)")
                             .font(.headline)
                             .foregroundColor(.gray)
                             .padding()
                     }
                     .frame(maxWidth: .infinity, maxHeight: 300)
                     .background(Color.black.opacity(0.1))
                     .cornerRadius(12)
                     
                #else
                // Display camera preview on real device
                CameraPreview(session: scannerViewModel.captureSession)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(12)
                #endif

                // Scan frame
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 2)
                    .frame(width: 250, height: 100)
                }
                .padding()

                // Status display
                if let error = scannerViewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                }
                 
                 if scannerViewModel.isScanning {
                     Text("Align the ISBN barcode with the scanning frame.")
                         .font(.headline)
                         .padding()
                     
                     #if targetEnvironment(simulator)
                     Button(action: {
                         scannerViewModel.simulateScan()
                     }) {
                         HStack {
                             Image(systemName: "barcode.viewfinder")
                             Text("Simulate scanning ISBNs: 9782760151420")
                         }
                         .padding()
                         .background(Color.orange)
                         .foregroundColor(.white)
                         .cornerRadius(10)
                     }
                     .padding()
                     #endif
                 } else if let code = scannerViewModel.scannedCode {
                     VStack {
                         Text("Success!")
                             .font(.headline)
                             .padding()
                         
                          Text("ISBN: \(code)")
                              .font(.title3)
                              .padding()
                        
                         Button(action: {
                             self.scannedISBN = code
                             UserDefaults.standard.set(code, forKey: "lastScannedISBN")
                             self.navigateToISBNInput = true
                         }){
                             HStack {
                                 Image(systemName: "magnifyingglass")
                                 Text("Find book information")
                             }
                             .padding()
                             .background(Color.orange)
                             .foregroundColor(.white)
                             .cornerRadius(10)
                         }
                          
                          Button(action: {
                              scannerViewModel.scannedCode = nil
                              scannerViewModel.setupCamera()
                          }) {
                              HStack {
                                  Image(systemName: "arrow.clockwise")
                                  Text("Rescan")
                              }
                              .padding()
                              .background(Color.white)
                              .foregroundColor(.orange)
                              .cornerRadius(10)
                          }
                          .padding(.top, 10)
                      }
                  }
                  
                  Spacer()
              }
              .padding()
          }
         .navigationTitle("Scan ISBN")
         .navigationDestination(isPresented: $navigateToISBNInput) {
             ISBNInputView()
                 .onAppear {
                     if !self.scannedISBN.isEmpty {
                         NotificationCenter.default.post(
                             name: NSNotification.Name("ProcessScannedISBN"),
                             object: nil,
                             userInfo: ["isbn": self.scannedISBN]
                         )
                     }
                 }
         }
         .onAppear {
             scannerViewModel.setupCamera()
         }
         .onDisappear {
             scannerViewModel.stopScanning()
         }
     }
}


#Preview {
    NavigationView {
        ScannerView()
            .environmentObject(LoginController())
            .environmentObject(ContentViewModel())
    }
}
