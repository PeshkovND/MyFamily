import Foundation
import AVKit
import UIKit
import AVFoundation
import Cache
import Utilities

public final class VideoPlayerView: UIView {
    private let videoPlayerView = VideoPlayer()
    private var playerLooper: AVPlayerLooper?
    private var token: NSKeyValueObservation?
    private let diskConfig = DiskConfig(name: "DiskCache")
    private let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    private lazy var storage: Cache.Storage<String, Data>? = {
        return try? Cache.Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self)
        )
    }()
    
    var onOpenBigPlayer: (() -> Void)?
    var onCloseBigPlayer: (() -> Void)?
    
    @objc private var player = AVPlayer()
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = appDesignSystem.colors.backgroundPrimary
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Video loading error"
        label.textColor = appDesignSystem.colors.backgroundPrimary
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    public init(audioPlayer: AVPlayer? = nil) {
        super.init(frame: .zero)
        self.addSubview(errorLabel)
        self.addSubview(activityIndicator)
        self.backgroundColor = appDesignSystem.colors.labelPrimary
        activityIndicator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        initPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initPlayer() {
        errorLabel.alpha = 0
        videoPlayerView.alpha = 0
        videoPlayerView.player = player
        addGestureRecognizers()
        player.actionAtItemEnd = .none
        player.volume = 0.0
        
        token = player.observe(\.currentItem) { (player, _) in
            if player.currentItem?.asset.isPlayable == true {
                DispatchQueue.main.async {
                    self.errorLabel.alpha = 0
                    self.activityIndicator.stopAnimating()
                    self.videoPlayerView.alpha = 1
                }
            }
            
            if player.currentItem?.asset.isPlayable == false {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.videoPlayerView.alpha = 0
                    self.player.replaceCurrentItem(with: nil)
                    self.errorLabel.alpha = 1
                }
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let item = notification.object as? AVPlayerItem {
            if item == player.currentItem {
                player.seek(to: CMTime.zero)
            }
        }
    }
    
    func pause() {
        player.pause()
    }
    
    public func play() {
        player.play()
    }
    
    public func addVideoToPlayer(videoUrl: URL) {
        self.errorLabel.alpha = 0
        self.activityIndicator.startAnimating()
        self.videoPlayerView.alpha = 0
        storage?.async.entry(forKey: videoUrl.absoluteString) { result in
            let playerItem: CachingPlayerItem
            switch result {
            case .failure:
                // The track is not cached.
                playerItem = CachingPlayerItem(url: videoUrl, customFileExtension: "mp4")
            case .success(let entry):
                // The track is cached.
                playerItem = CachingPlayerItem(data: entry.object, url: videoUrl, mimeType: "video/mp4", fileExtension: "mp4")
            }
            playerItem.delegate = self
            self.player.replaceCurrentItem(with: playerItem)
            self.player.automaticallyWaitsToMinimizeStalling = false
        }
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openBigPlayer))
        addGestureRecognizer(tap)
    }
    
    @objc
    private func openBigPlayer() {
        
        let player = self.player
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        player.volume = 1.0
        playerViewController.transitioningDelegate = self
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        if let windowScene = scene as? UIWindowScene {
            self.onOpenBigPlayer?()
            windowScene.keyWindow?.rootViewController?.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    public override func layoutSubviews() {
        addSubview(videoPlayerView)
        videoPlayerView.frame = bounds
    }
}

extension VideoPlayerView: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        self.player.play()
        self.player.volume = 0.0
        self.onCloseBigPlayer?()
        return nil
    }
}

extension VideoPlayerView: CachingPlayerItemDelegate {
    public func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString) { _ in }
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded) / \(bytesExpected)")
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        player.replaceCurrentItem(with: nil)
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.videoPlayerView.alpha = 0
            self.player.replaceCurrentItem(with: nil)
            self.errorLabel.alpha = 1
        }
    }
    
    public func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        if player.currentItem != nil {
            self.errorLabel.alpha = 0
            self.activityIndicator.stopAnimating()
            self.videoPlayerView.alpha = 1
        }
    }
}
