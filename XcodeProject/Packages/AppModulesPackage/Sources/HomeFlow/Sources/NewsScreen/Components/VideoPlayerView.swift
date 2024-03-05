import Foundation
import UIKit
import AVFoundation

final class VideoPlayerView: UIView {
    let videoPlayerView = VideoPlayer()
    let videoUrl: URL
    
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
        
        player.volume = 0.0
        player.play()
        token = player.observe(\.currentItem, changeHandler: { (player, _) in
            if player.items().count == 1 {
                self.addVideoToPlayer()
            }
        })
        
        token = player.observe(\.status, changeHandler: { (player, _) in
            if player.status == .readyToPlay {
                self.activityIndicator.stopAnimating()
            }
        })
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
    }
    
    override func layoutSubviews() {
        addSubview(videoPlayerView)
        videoPlayerView.frame = bounds
    }
}
