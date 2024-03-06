import Foundation
import AVKit
import UIKit
import AVFoundation
import AppDesignSystem

final class AudioPlayerView: UIView {
    @objc var player: AVQueuePlayer?
    var audioURL: URL?
    private var token: NSKeyValueObservation?
    private var changeTrackToken: NSKeyValueObservation?
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
        
        if let asset = player?.currentItem?.asset as? AVURLAsset,
           asset.url == self.audioURL {
            self.slider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
        }
    }
    
    @objc
    private func sliderDidMoved() {
        let time = CMTime(
            seconds: Double(slider.value),
            preferredTimescale: 1000
        )
        
        player?.seek(to: time) { [weak self] _ in
            self?.setupObserver()
        }
    }
    
    @objc
    private func sliderStartMoving() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer as Any)
            timeObserver = nil
        }
    }
    
    private func setupObserver() {
        timeObserver = player?.addPeriodicTimeObserver(
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
    
    // swiftlint:disable function_body_length
    func setupPlayerData() {
        if let asset = player?.currentItem?.asset as? AVURLAsset {
            if asset.url == self.audioURL {
                slider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
                if let observer = timeObserver {
                    player?.removeTimeObserver(observer)
                    timeObserver = nil
                }
                setupObserver()
                if player?.currentItem?.status == .readyToPlay {
                    self.slider.maximumValue = Float(player?.currentItem?.duration.seconds ?? 0.0)
                }
                
                self.playButton.setImage(
                    UIImage(systemName: "pause")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            } else {
                if let observer = timeObserver {
                    player?.removeTimeObserver(observer)
                    timeObserver = nil
                }
                slider.value = 0
                
                self.playButton.setImage(
                    UIImage(systemName: "play")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            }
        }
        
        token = player?.observe(\.currentItem?.status) { (player, _) in
            if player.currentItem?.status == .readyToPlay {
                self.slider.maximumValue = Float(player.currentItem?.duration.seconds ?? 0.0)
            }
        }
        // swiftlint:disable closure_body_length
        changeTrackToken = player?.observe(\.currentItem) { (player, _) in
            if let asset = player.currentItem?.asset as? AVURLAsset {
                if asset.url != self.audioURL {
                    if let timeObserver = self.timeObserver {
                        self.player?.removeTimeObserver(timeObserver)
                        self.timeObserver = nil
                    }
                    self.slider.value = 0
                    self.playButton.setImage(
                        UIImage(systemName: "play")?.withTintColor(
                            .white,
                            renderingMode: .alwaysOriginal),
                        for: .normal
                    )
                } else {
                    self.playButton.setImage(
                        UIImage(systemName: "pause")?.withTintColor(
                            .white,
                            renderingMode: .alwaysOriginal),
                        for: .normal
                    )
                }
            }
        }
    }

    // swiftlint:disable function_body_length
    @objc func play() {
        if let asset = player?.currentItem?.asset as? AVURLAsset,
           asset.url == self.audioURL {
            if player?.timeControlStatus == .playing {
                player?.pause()
                playButton.setImage(
                    UIImage(systemName: "play")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            } else {
                player?.play()
                playButton.setImage(
                    UIImage(systemName: "pause")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            }
        } else {
            if ((player?.items().isEmpty) != nil) {
                self.playButton.setImage(
                    UIImage(systemName: "pause")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            } else {
                self.playButton.setImage(
                    UIImage(systemName: "play")?.withTintColor(
                        .white,
                        renderingMode: .alwaysOriginal),
                    for: .normal
                )
            }
            addAudioToPlayer(url: audioURL)
            let time = CMTime(
                seconds: Double(slider.value),
                preferredTimescale: 1000
            )
            
            player?.seek(to: time)
            player?.play()
        }
    }
    
    
    private func addAudioToPlayer(url: URL?) {
        guard let url = url else { return }
        player?.removeAllItems()
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player?.insert(item, after: player?.items().last)
        player?.actionAtItemEnd = .pause
        setupObserver()
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(play))
        playButton.addGestureRecognizer(tap)
    }
}
