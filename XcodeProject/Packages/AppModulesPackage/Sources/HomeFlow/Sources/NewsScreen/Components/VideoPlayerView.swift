import Foundation
import AVKit
import UIKit
import AVFoundation

final class VideoPlayerView: UIView {
    let videoPlayerView = VideoPlayer()
    let videoUrl: URL
    
    var playerLooper: AVPlayerLooper?
    
    @objc private var player = AVQueuePlayer()
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private var token: NSKeyValueObservation?
    
    init(videoURL: URL) {
        self.videoUrl = videoURL
        super.init(frame: .zero)
        
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        initPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initPlayer() {
        videoPlayerView.player = player
        addVideoToPlayer()
        addGestureRecognizers()
        
        player.volume = 0.0
        player.play()
        
        token = player.observe(\.status) { (player, _) in
            if player.status == .readyToPlay {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    private func addVideoToPlayer() {
        let asset = AVURLAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: player.items().last)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
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
            windowScene.keyWindow?.rootViewController?.present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
    
    override func layoutSubviews() {
        addSubview(videoPlayerView)
        videoPlayerView.frame = bounds
    }
}

extension VideoPlayerView: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
        self.player.play()
        self.player.volume = 0.0
        return nil
    }
}
