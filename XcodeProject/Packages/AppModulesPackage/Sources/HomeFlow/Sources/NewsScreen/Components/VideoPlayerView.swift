import Foundation
import AVKit
import UIKit
import AVFoundation

final class VideoPlayerView: UIView {
    private let videoPlayerView = VideoPlayer()
    private var playerLooper: AVPlayerLooper?
    private var token: NSKeyValueObservation?
    
    @objc private var player = AVQueuePlayer()
    
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .black
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Video loading error"
        label.textColor = .black
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(errorLabel)
        self.addSubview(activityIndicator)
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
        player.removeAllItems()
        errorLabel.alpha = 0
        videoPlayerView.alpha = 0
        videoPlayerView.player = player
        addGestureRecognizers()
        
        player.volume = 0.0
        
        token = player.observe(\.currentItem) { (player, _) in
            if player.currentItem?.asset.isPlayable == true {
                self.errorLabel.alpha = 0
                self.activityIndicator.stopAnimating()
                self.videoPlayerView.alpha = 1
            }
            
            if player.currentItem?.asset.isPlayable == false {
                self.activityIndicator.stopAnimating()
                self.videoPlayerView.alpha = 0
                self.player.removeAllItems()
                self.errorLabel.alpha = 1
                player.removeAllItems()
            }
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    public func addVideoToPlayer(videoUrl: URL) {
        self.player.removeAllItems()
        let asset = AVURLAsset(url: videoUrl)
        let keys: [String] = ["playable"]
        
        // swiftlint:disable closure_body_length
        asset.loadValuesAsynchronously(forKeys: keys, completionHandler: {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async {
                    let item = AVPlayerItem(asset: asset)
                    self.player.insert(item, after: nil)
                    self.playerLooper = AVPlayerLooper(player: self.player, templateItem: item)
                }
            case .failed:
                self.activityIndicator.stopAnimating()
                self.videoPlayerView.alpha = 0
                self.player.removeAllItems()
                self.errorLabel.alpha = 1
                self.player.removeAllItems()
            default:
                break
            }
        })
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
