//
//  PlayerViewController.swift
//  VideoCachingHLS
//
//  Created by Faraz Ahmed Khan on 01/03/2022.
//

import UIKit
import AVFoundation
import BMPlayer

class PlayerViewController: UIViewController {
    
    //MARK: - VARIABLES
    var configuration : URLSessionConfiguration?
    var downloadSession : AVAssetDownloadURLSession?
    var downloadIdentifier = "sampleCache"
    var assetTitle = ""
    var titleCount = 0
    var videoURL = "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8"
    var viewModel = PlayerViewModel()
    var tempURL : URL?

    //MARK: - UI PROPERTIES
    fileprivate lazy var bmPlayer : BMPlayer = {
       let p = BMPlayer()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.heightAnchor.constraint(equalToConstant: 250).isActive = true
        return p
    }()
    
    fileprivate lazy var playerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()
    
    fileprivate lazy var downloadLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = ""
        l.textColor = .white
        l.minimumScaleFactor = 0.5
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    fileprivate lazy var clearCacheButton: UIButton = {
       let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Clear Cache", for: .normal)
        b.titleLabel?.textColor = .white
        b.addTarget(self, action: #selector(clearCache), for: .touchUpInside)
        return b
    }()
    
    var playerAV = AVPlayer()
        
    //MARK: - LIFECYCLE METHODS
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(suspending), name: UIApplication.willTerminateNotification, object: nil)
        self.assetTitle = "title\(titleCount)"
        self.setupViews()
        self.setupPlayer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    @objc func suspending() {
        print("suspending...")
        self.downloadSession?.finishTasksAndInvalidate()
    }
    
    //MARK: - SETUP
    
    fileprivate func setupViews() {
        
        view.addSubview(bmPlayer)
        bmPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bmPlayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        bmPlayer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        view.addSubview(downloadLabel)
        downloadLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        downloadLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.addSubview(clearCacheButton)
        clearCacheButton.centerXAnchor.constraint(equalTo: downloadLabel.centerXAnchor).isActive = true
        clearCacheButton.topAnchor.constraint(equalTo: downloadLabel.bottomAnchor, constant: -10).isActive = true
        clearCacheButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        clearCacheButton.heightAnchor.constraint(equalToConstant: 150).isActive = true

        self.view.backgroundColor = .black
    }
    
    fileprivate func setupPlayer() {
        let localFilePath = UserDefaults.standard.url(forKey: "assetPath")
        guard let localFilePath = localFilePath else {
            self.initializePlayer(videoUrl: URL(string: videoURL)!)
            setupAssetDownload()
            clearCacheButton.isHidden = true
            return
        }
        self.downloadLabel.text = "Cached Video"
        clearCacheButton.isHidden = false
        self.initializePlayer(videoUrl: localFilePath)
    }
    
    func initializePlayer(videoUrl: URL) {
        if FileManager.default.fileExists(atPath: videoUrl.path) {
            print("videoUrl exist @ \(videoUrl.path)")
        }
        let asset = BMPlayerResource(url: videoUrl)
        bmPlayer.setVideo(resource: asset)
//        bmPlayer
        bmPlayer.play()
    }
    
    //MARK: - DOWNLOAD METHODS
    func setupAssetDownload() {
        // Create new background session configuration.
        titleCount += 1
        self.assetTitle = "title\(titleCount)"
        
        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
        
        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
                                                    assetDownloadDelegate: self,
                                                    delegateQueue: OperationQueue.main)
        configuration?.timeoutIntervalForResource = 5
        let url = URL(string: videoURL)!// HLS Asset URL
        let asset = AVURLAsset(url: url)
        
        // Create new AVAssetDownloadTask for the desired asset
        let downloadTask = downloadSession?.makeAssetDownloadTask(asset: asset,
                                                                  assetTitle: assetTitle,
                                                                  assetArtworkData: nil,
                                                                  options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 200000, AVAssetDownloadTaskPrefersHDRKey: false])
        // Start task and begin download
        downloadTask?.resume()
        
        // Create standard playback items and begin playback
        guard let downloadTask = downloadTask else {
            print("❌❌❌")
            print("downloadTask is nil")
            print("❌❌❌")
            return
        }

    }
    
    func restorePendingDownloads() {
        // Create session configuration with ORIGINAL download identifier
        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
     
        // Create a new AVAssetDownloadURLSession
        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
                                                    assetDownloadDelegate: self,
                                                    delegateQueue: OperationQueue.main)
        configuration?.timeoutIntervalForResource = 5
        // Grab all the pending tasks associated with the downloadSession
        downloadSession?.getAllTasks { tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard let downloadTask = task as? AVAssetDownloadTask else { break }
                // Restore asset, progress indicators, state, etc...
                let asset = downloadTask.urlAsset
            }
        }
    }
    
    //MARK: - CLEAR CACHE
    @objc func clearCache(sender: UIButton) {
        print("clear cache tapped")
        let localFilePath = UserDefaults.standard.url(forKey: "assetPath")
        guard let localFilePath = localFilePath else {
            return
        }
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: localFilePath.path) {
                try fileManager.removeItem(atPath: localFilePath.path)
                print("🗑 Temp File Deleted! 🗑")
                let files = try fileManager.contentsOfDirectory(atPath: localFilePath.deletingLastPathComponent().deletingLastPathComponent().path)
                print("all files after deleting temp files: \(files)")
                UserDefaults.standard.removeObject(forKey: "assetPath")
                clearCacheButton.isHidden = true
            }
        } catch {
            print("🔥🔥🔥")
            print(error.localizedDescription)
            print("🔥🔥🔥")
        }
    }
    
}

extension PlayerViewController: AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fileManager = FileManager.default
        self.assetTitle = "title\(titleCount)"
        // Do not move the asset from the download location
        let docsUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!

        let fileExtension = location.pathExtension
        let startingURL = location
        let savedVideoURL = docsUrl.appendingPathComponent("\(self.assetTitle).\(fileExtension)")
        
        let fileMngr = FileManager.default
        
        if !fileMngr.fileExists(atPath: savedVideoURL.path) {
            do {
                try fileMngr.copyItem(at: startingURL, to: savedVideoURL)
            }
            catch {
                print(error.localizedDescription)
                return
            }
        }

        let url = location
        do {
            if fileManager.fileExists(atPath: url.deletingLastPathComponent().path) {
                try fileManager.removeItem(atPath: url.deletingLastPathComponent().path)
                print("🗑 Temp File Deleted! 🗑")
                let files = try fileManager.contentsOfDirectory(atPath: url.deletingLastPathComponent().deletingLastPathComponent().path)
                print("all files after deleting temp files: \(files)")
            }
        } catch {
            print("🔥🔥🔥")
            print(error.localizedDescription)
            print("🔥🔥🔥")
        }
//        viewModel.saveVideo(to: savedVideoURL, from: startingURL)
        UserDefaults.standard.set(savedVideoURL, forKey: "assetPath")
        clearCacheButton.isHidden = false
        downloadLabel.text = "Cached 100%"
        let currentTime = Double(CMTimeGetSeconds((bmPlayer.avPlayer?.currentItem?.currentTime())!))
        let asset = BMPlayerResource(url: savedVideoURL)
        bmPlayer.setVideo(resource: asset)
        bmPlayer.seek(currentTime, completion: nil)
        bmPlayer.play()
    }
    
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
        // Iterate through the loaded time ranges
        for value in loadedTimeRanges {
            // Unwrap the CMTimeRange from the NSValue
            let loadedTimeRange = value.timeRangeValue
            // Calculate the percentage of the total expected asset duration
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        percentComplete *= 100
        print("Caching: \(String(format: "%.2f", percentComplete))%")
        downloadLabel.text = "Caching: \(String(format: "%.2f", percentComplete))%"
        // Update UI state: post notification, update KVO state, invoke callback, etc.
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didCompleteFor mediaSelection: AVMediaSelection) {
        print(mediaSelection)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error?.localizedDescription)
    }
    
}


