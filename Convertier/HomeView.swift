//
//  HomeView.swift
//  Convertier
//
//  Created by Nicolò Curioni Dacomat on 05/06/24.
//

import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var showFilePicker = false
    @State private var inputURL: URL?
    @State private var outputURL: URL?
    @State private var isConverting = false
    @State private var conversionStatus = ""
    
    var body: some View {
        VStack {
            if let inputURL = inputURL {
                Text("Selected File: \(inputURL.lastPathComponent)")
            }
            Button(action: {
                self.showFilePicker.toggle()
            }) {
                Text("Choose file")
            }
            .padding()
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.movie],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        self.inputURL = url
                        self.convertToMP4(inputURL: url)
                    }
                case .failure(let error):
                    print("Failed to select file: \(error.localizedDescription)")
                }
            }
            if isConverting {
                ProgressView("Converting...")
            }
            if let outputURL = outputURL {
                Text("Converted File: \(outputURL.lastPathComponent)")
                Button(action: {
                    NSWorkspace.shared.open(outputURL)
                }) {
                    Text("Open File")
                }
                .padding()
            }
            if !conversionStatus.isEmpty {
                Text(conversionStatus)
                    .padding()
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private func convertToMP4(inputURL: URL) {
        isConverting = true
        conversionStatus = ""
        
        let asset = AVAsset(url: inputURL)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        
        let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        exportSession?.outputURL = outputPath
        exportSession?.outputFileType = .mp4
        
        exportSession?.exportAsynchronously {
            DispatchQueue.main.async {
                self.isConverting = false
                switch exportSession?.status {
                case .completed:
                    self.outputURL = outputPath
                case .failed:
                    self.conversionStatus = "Failed to convert file: \(exportSession?.error?.localizedDescription ?? "Unknown error")"
                case .cancelled:
                    self.conversionStatus = "Conversion cancelled."
                default:
                    self.conversionStatus = "Unknown status."
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
