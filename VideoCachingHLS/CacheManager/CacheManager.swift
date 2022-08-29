////
////  CacheManager.swift
////  VideoCachingHLS
////
////  Created by Faraz Ahmed Khan on 01/03/2022.
////
//
//import Foundation
//import AVFoundation
//
//class CacheManager {
//    
//    var configuration = AVAssetDownloadURLSession(configuration: configuration,
//                                                  assetDownloadDelegate: self,
//                                                  delegateQueue: OperationQueue.main)
//    var downloadSession : AVAssetDownloadURLSession?
//    var downloadIdentifier = ""
//    
//    func setupAssetDownload() {
//        // Create new background session configuration.
//        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
//        
//        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
//        downloadSession = AVAssetDownloadURLSession(configuration: configuration,
//                                                    assetDownloadDelegate: self,
//                                                    delegateQueue: OperationQueue.main)
//        let url = URL(string: "")!// HLS Asset URL
//        let asset = AVURLAsset(url: url)
//     
//        // Create new AVAssetDownloadTask for the desired asset
//        let downloadTask = downloadSession.makeAssetDownloadTask(asset: asset,
//                                                                 assetTitle: assetTitle,
//                                                                 assetArtworkData: nil,
//                                                                 options: nil)
//        // Start task and begin download
//        downloadTask?.resume()
//    }
//    
//    func restorePendingDownloads() {
//        // Create session configuration with ORIGINAL download identifier
//        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
//     
//        // Create a new AVAssetDownloadURLSession
//        downloadSession = AVAssetDownloadURLSession(configuration: configuration,
//                                                    assetDownloadDelegate: self,
//                                                    delegateQueue: OperationQueue.main)
//     
//        // Grab all the pending tasks associated with the downloadSession
//        downloadSession?.getAllTasks { tasksArray in
//            // For each task, restore the state in the app
//            for task in tasksArray {
//                guard let downloadTask = task as? AVAssetDownloadTask else { break }
//                // Restore asset, progress indicators, state, etc...
//                let asset = downloadTask.urlAsset
//            }
//        }
//    }
//    
//    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
//        var percentComplete = 0.0
//        // Iterate through the loaded time ranges
//        for value in loadedTimeRanges {
//            // Unwrap the CMTimeRange from the NSValue
//            let loadedTimeRange = value.timeRangeValue
//            // Calculate the percentage of the total expected asset duration
//            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
//        }
//        percentComplete *= 100
//        // Update UI state: post notification, update KVO state, invoke callback, etc.
//    }
//    
//    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
//        // Do not move the asset from the download location
//        UserDefaults.standard.set(location.relativePath, forKey: "assetPath")
//    }
//    
//}
//
//extension CacheManager: AVAssetDownloadDelegate {
//    
//}
