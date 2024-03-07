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
    
    private let playImage = UIImage(systemName: "play")?.withTintColor(
        .white,
        renderingMode: .alwaysOriginal
    )
    
    private let pauseImage = UIImage(systemName: "pause")?.withTintColor(
        .white,
        renderingMode: .alwaysOriginal
    )
    
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
        
        playButton.setImage(playImage, for: .normal)

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
        removeObserver()
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
    
    private func removeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayerData() {
        if let asset = player?.currentItem?.asset as? AVURLAsset {
            if asset.url == self.audioURL {
                removeObserver()
                slider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
                setupObserver()
                setupSliderMaximumValue()
                playButton.setImage(
                    player?.timeControlStatus == .playing
                    ? pauseImage
                    : playImage,
                    for: .normal
                )
            } else {
                removeObserver()
                slider.value = 0
                self.playButton.setImage(playImage, for: .normal)
            }
        }
        
        token = player?.observe(\.currentItem?.status) { (player, _) in
            self.setupSliderMaximumValue()
        }
        changeTrackToken = player?.observe(\.currentItem) { (player, _) in
            if let asset = player.currentItem?.asset as? AVURLAsset,
               asset.url != self.audioURL {
                self.changeTrack()
            }
        }
    }
    
    private func setupSliderMaximumValue() {
        if player?.currentItem?.status == .readyToPlay {
            self.slider.maximumValue = Float(player?.currentItem?.duration.seconds ?? 0.0)
        }
    }
    
    private func changeTrack() {
        removeObserver()
        self.slider.value = 0
        self.playButton.setImage(playImage, for: .normal)
    }
    
    @objc func playButtonTapped() {
        if let asset = player?.currentItem?.asset as? AVURLAsset,
           asset.url == self.audioURL {
            if player?.timeControlStatus == .playing {
                pause()
            } else {
                play()
            }
        } else {
            addAudioToPlayer(url: audioURL)
            play()
        }
    }
    
    private func play() {
        let time = CMTime(
            seconds: Double(slider.value),
            preferredTimescale: 1000
        )
        player?.seek(to: time)
        player?.play()
        playButton.setImage(pauseImage, for: .normal)
    }
    
    private func pause() {
        player?.pause()
        playButton.setImage(playImage, for: .normal)
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playButton.addGestureRecognizer(tap)
    }
}
