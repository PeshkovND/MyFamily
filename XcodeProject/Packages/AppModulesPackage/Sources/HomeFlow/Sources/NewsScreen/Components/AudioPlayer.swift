import Foundation
import AVKit
import UIKit
import AVFoundation
import AppDesignSystem

final class AudioPlayer: UIView {
    @objc private var player = AVQueuePlayer()
    private var token: NSKeyValueObservation?
    private var timeObserver: Any?
    
    private let playButton: ActionButton = {
        let button = ActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = appDesignSystem.colors.backgroundSecondaryVariant
        return button
    }()
    
    private let slider: UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumValue = 0.0
        view.isContinuous = false
        view.minimumTrackTintColor = appDesignSystem.colors.backgroundSecondaryVariant
        view.maximumTrackTintColor = .gray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(slider)
        addSubview(playButton)
        
        playButton.setImage(
            UIImage(systemName: "play")?.withTintColor(
                .white,
                renderingMode: .alwaysOriginal),
            for: .normal
        )

        playButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        slider.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(playButton.snp.trailing).inset(-12)
            $0.trailing.equalToSuperview()
        }
        
        addGestureRecognizers()
        slider.addTarget(self, action: #selector(sliderDidMoved), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderStartMoving), for: .touchDown)
        
        player.actionAtItemEnd = .pause
        setupObserver()
    }
    
    @objc
    private func sliderDidMoved() {
        let time = CMTime(
            seconds: Double(slider.value),
            preferredTimescale: 1
        )
        
        player.seek(to: time) { [weak self] _ in
            self?.setupObserver()
        }
    }
    
    @objc
    private func sliderStartMoving() {
        player.removeTimeObserver(timeObserver as Any)
        timeObserver = nil
    }
    
    private func setupObserver() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 1,
                preferredTimescale: 1000
            ),
            queue: DispatchQueue.main
        ) { time in
            self.slider.value = Float(time.seconds)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func play() {
        if player.timeControlStatus == .playing {
            player.pause()
            playButton.setImage(
                UIImage(systemName: "play")?.withTintColor(
                    .white,
                    renderingMode: .alwaysOriginal),
                for: .normal
            )
        } else {
            player.play()
            playButton.setImage(
                UIImage(systemName: "pause")?.withTintColor(
                    .white,
                    renderingMode: .alwaysOriginal),
                for: .normal
            )
        }
    }
    
    
    public func addAudioToPlayer(videoUrl: URL) {
        let asset = AVURLAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: player.items().last)
        
        token = player.observe(\.currentItem?.status) { (player, _) in
            if player.currentItem?.status == .readyToPlay {
                self.slider.maximumValue = Float(player.currentItem?.duration.seconds ?? 0.0)
            }
        }
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(play))
        playButton.addGestureRecognizer(tap)
    }
}
