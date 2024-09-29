//
//  VideoPickerExampleView.swift
//  VidoooEditor
//
//  Created by Rezaul Islam on 28/9/24.
//

import SwiftUI
import PhotosUI
import AVFoundation
import MobileCoreServices
import DPVideoMerger_Swift
import AVKit

struct VideoPickerExampleView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var pickedVideos: [AVAsset] = []
    @State private var videoURLs: [URL] = [] // Array to store the URLs of the selected videos
    @State private var isProcessing = false
    @State private var exportURL: URL?
    @State private var mergedURL: URL?
    @State private var showExportSuccess = false
    
    var body: some View {
        VStack {
            Text("Pick 2 Videos to Merge")
                .font(.title)
                .padding()
            
            // Video picker button
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 2,
                matching: .videos
            ) {
                Text("Pick Videos")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItems) { _ in
                loadSelectedVideos()
            }
            
            // Merge and export button
            if pickedVideos.count == 2 {
                Button(action: {
                    // Example usage: Print the URLs
                    print("Selected Video URLs: \(videoURLs)")
                    mergeVideo()
                }) {
                    Text("Merge Videos")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isProcessing)
            }
            
            if isProcessing {
                ProgressView("Merging Videos...")
            }
            
            if showExportSuccess, let exportURL {
                Text("Video exported to: \(exportURL.absoluteString)")
                    .font(.footnote)
                    .padding()
                    .foregroundColor(.green)
               
            }
            if let mergedURL = mergedURL{
                VideoPlayer(player: AVPlayer(url: mergedURL))
            }
        }
        .padding()
    }
    
    
    func mergeVideo(){
        DPVideoMerger().mergeVideos(withFileURLs: videoURLs as! [URL], completion: {(_ mergedVideoFile: URL?, _ error: Error?) -> Void in
            if error != nil {
                let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
                print(errorMessage)
                
                return
            }
            else{
                print("mergedVideoFile \(mergedVideoFile)")
                mergedURL = mergedVideoFile
            }
             
        })
    }
    
    
    // Load selected videos as AVAssets and save their URLs
    private func loadSelectedVideos() {
        pickedVideos.removeAll()
        videoURLs.removeAll() // Clear the URLs
        
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                        do {
                            try data.write(to: tempURL)
                            let asset = AVAsset(url: tempURL)
                            pickedVideos.append(asset)
                            videoURLs.append(tempURL) // Save the URL
                        } catch {
                            print("Error writing video data to temp file: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Error loading video: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    VideoPickerExampleView()
}
