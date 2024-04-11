import Foundation
import AVKit
import UIKit
import AVFoundation
import AppDesignSystem
import Utilities
import Cache

final class AudioPlayerView: UIView {
    @objc var player: AVPlayer?
    var audioURL: URL?
    private var token: NSKeyValueObservation?
    private var changeTrackToken: NSKeyValueObservation?
    private var timeObserver: Any?
    private let diskConfig = DiskConfig(name: "DiskCache")
    private let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    private lazy var storage: Cache.Storage<String, Data>? = {
        return try? Cache.Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self)
        )
    }()
    
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
        if let asset = player?.currentItem?.asset as? AVURLAsset,
           let audioURLLastPathComponent = self.audioURL?.lastPathComponent,
           asset.url.lastPathComponent == audioURLLastPathComponent + ".mp3" {
            let time = CMTime(
                seconds: Double(slider.value),
                preferredTimescale: 1000
            )
            
            player?.seek(to: time) { [weak self] _ in
                self?.setupSliderObserver()
            }
        }
    }
    
    @objc
    private func sliderStartMoving() {
        removeSliderObserver()
    }
    
    private func setupSliderObserver() {
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
    
    private func setupTrackEndedObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioDidEnded(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    private func removeSliderObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func removeTrackEndedObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayerData() {
        if let asset = player?.currentItem?.asset as? AVURLAsset {
            if let audioURLLastPathComponent = self.audioURL?.lastPathComponent,
            asset.url.lastPathComponent == audioURLLastPathComponent + ".mp3" {
                removeSliderObserver()
                slider.value = Float(player?.currentItem?.currentTime().seconds ?? 0)
                setupSliderObserver()
                setupSliderMaximumValue()
                if player?.timeControlStatus == .playing {
                    playButton.setImage(pauseImage, for: .normal)
                    removeTrackEndedObserver()
                    setupTrackEndedObserver()
                } else {
                    playButton.setImage(playImage, for: .normal)
                }
            } else {
                removeSliderObserver()
                slider.value = 0
                self.playButton.setImage(playImage, for: .normal)
            }
        }
        
        token = player?.observe(\.currentItem?.status) { _, _  in
            self.setupSliderMaximumValue()
        }
        changeTrackToken = player?.observe(\.currentItem) { (player, _) in
            if let asset = player.currentItem?.asset as? AVURLAsset,
               let audioURLLastPathComponent = self.audioURL?.lastPathComponent,
               asset.url.lastPathComponent != audioURLLastPathComponent + ".mp3" {
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
        self.removeSliderObserver()
        self.slider.value = 0
        self.playButton.setImage(self.playImage, for: .normal)
    }
    
    @objc func playButtonTapped() {
        if let asset = player?.currentItem?.asset as? AVURLAsset,
           let audioURLLastPathComponent = self.audioURL?.lastPathComponent,
           asset.url.lastPathComponent == audioURLLastPathComponent + ".mp3" {
            if player?.timeControlStatus == .playing {
                pause()
            } else {
                play()
            }
        } else {
            addAudioToPlayer(url: audioURL)
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
        
        setupTrackEndedObserver()
    }
    
    private func pause() {
        player?.pause()
        playButton.setImage(playImage, for: .normal)
        
        removeTrackEndedObserver()
    }
    
    private func addAudioToPlayer(url: URL?) {
        player?.replaceCurrentItem(with: nil)
        guard let url = url else { return }
        storage?.async.entry(forKey: url.absoluteString) { result in
            let playerItem: CachingPlayerItem
            switch result {
            case .failure:
                // The track is not cached.
                playerItem = CachingPlayerItem(url: url, customFileExtension: "mp3")
            case .success(let entry):
                // The track is cached.
                playerItem = CachingPlayerItem(data: entry.object, url: url, mimeType: "audio/mp3", fileExtension: "mp3")
            }
            playerItem.delegate = self
            DispatchQueue.main.async {
                self.player?.replaceCurrentItem(with: playerItem)
                self.setupSliderObserver()
//                self.setupTrackEndedObserver()
            }
        }
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playButton.addGestureRecognizer(tap)
    }
    
    @objc private func audioDidEnded(notification: Notification) {
        if let item = notification.object as? AVPlayerItem {
            if item == player?.currentItem {
                removeSliderObserver()
                self.slider.value = 0
                self.playButton.setImage(playImage, for: .normal)
                self.player?.replaceCurrentItem(with: nil)
                self.player?.pause()
                removeTrackEndedObserver()
            }
        }
    }
}

extension AudioPlayerView: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.url.absoluteString) { _ in }
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded) / \(bytesExpected)")
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        self.play()
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        self.player?.replaceCurrentItem(with: nil)
    }
}
