import Foundation
import AVKit
import UIKit
import AVFoundation
import AppDesignSystem

final class AudioPlayer: UIView {
    
    @objc private var player = AVQueuePlayer()
    
    private let playButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("play", for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(playButton)
        playButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.center.equalToSuperview()
        }
        
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pause() {
        player.pause()
    }
    
    @objc func play() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    public func addAudioToPlayer(videoUrl: URL) {
        player.actionAtItemEnd = .pause
        let asset = AVURLAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: player.items().last)
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(play))
        playButton.addGestureRecognizer(tap)
    }
}
