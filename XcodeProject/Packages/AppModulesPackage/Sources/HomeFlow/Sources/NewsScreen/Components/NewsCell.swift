import UIKit
import Foundation
import Utilities
import AppDesignSystem
import AVKit

final class NewsCell: UITableViewCell {
    
    struct Model {
        let userImageURL: URL?
        let name: String
        let contentLabel: String?
        let mediaContent: MediaContent?
        var commentsCount: Int
        let likeButtonTapAction: () -> Void
        let profileTapAction: () -> Void
        let commentButtonTapAction: () -> Void
        let shareButtonTapAction: () -> Void
        let onAudioLoadingError: () -> Void
        
        let likesModel: LikesModel
        let audioPlayer: AVPlayer
    }
    
    struct LikesModel {
        var likesCount: Int
        var isLiked: Bool
    }

    private enum Layout {
        static let cardLabelConstraintValue = CGFloat(16)
        static let containerWidthMultiplier = CGFloat(0.8)
    }
    
    private var isAudioPlayerPlaingBeforeBigPlayerOpening = false

    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = 40/2
        userImageView.clipsToBounds = true
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        return userImageView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.body.withSize(16)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    private let userInfoContainerButton: ActionButton = {
        let button = ActionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likeButton: ActionButton = {
        var filled = UIButton.Configuration.borderless()
        filled.imagePlacement = .leading
        filled.imagePadding = 4
        filled.baseForegroundColor = .black
        
        let button = ActionButton(configuration: filled, primaryAction: nil)
        let icon = UIImage(systemName: "heart")
        button.setImage(icon, for: .normal)
        return button
    }()
    
    private let commentButton: ActionButton = {
        var filled = UIButton.Configuration.borderless()
        filled.imagePlacement = .leading
        filled.imagePadding = 4
        filled.baseForegroundColor = .black
        
        let button = ActionButton(configuration: filled, primaryAction: nil)
        let icon = UIImage(systemName: "message")
        button.setImage(icon, for: .normal)
        
        return button
    }()
    
    private let shareButton: ActionButton = {
        var filled = UIButton.Configuration.borderless()
        filled.imagePlacement = .leading
        filled.imagePadding = 4
        filled.baseForegroundColor = .black
        
        let button = ActionButton(configuration: filled, primaryAction: nil)
        let icon = UIImage(systemName: "paperplane")
        button.setImage(icon, for: .normal)
        
        return button
    }()
    
    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var videoContainer: VideoPlayerView = {
        let view = VideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = appDesignSystem.colors.labelPrimary
        label.font = appDesignSystem.typography.body.withSize(16)
        label.numberOfLines = 0
        return label
    }()
    
    private let audioView: AudioPlayerView = {
        let view = AudioPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(userInfoContainerButton)
        userInfoContainerButton.addSubview(userImageView)
        userInfoContainerButton.addSubview(usernameLabel)
        setupUserInfoConstraints()
        setupControlButtonConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func setupLayout(model: Model) {
        setupContentConstraints(model: model)
        setupData(model: model)
    }
    
    private func setupUserInfoConstraints() {
        userInfoContainerButton.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
            $0.top.equalTo(contentView.snp.top).inset(8)
            $0.height.equalTo(40)
        }
        
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.top.equalTo(contentView.snp.top).inset(8)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.centerY.equalTo(userImageView.snp.centerY).inset(8)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
        }
    }
    
    // swiftlint:disable function_body_length
    private func setupContentConstraints(model: Model) {
        
        if let contentText = model.contentLabel {
            contentView.addSubview(contentLabel)
            contentLabel.text = contentText
            contentLabel.snp.removeConstraints()
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(userImageView.snp.bottom).inset(-8)
                $0.leading.equalTo(contentView.snp.leading).inset(16)
                $0.trailing.equalTo(contentView.snp.trailing).inset(16)
                if model.mediaContent == nil {
                    $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                }
            }
        } else {
            self.contentLabel.removeFromSuperview()
        }
        
        switch model.mediaContent {
        case .Video(let url):
            guard let url = url else { return }
            contentView.addSubview(videoContainer)
            videoContainer.addVideoToPlayer(videoUrl: url)
            videoContainer.onOpenBigPlayer = {
                if model.audioPlayer.timeControlStatus == .playing {
                    self.isAudioPlayerPlaingBeforeBigPlayerOpening = true
                    model.audioPlayer.pause()
                } else {
                    self.isAudioPlayerPlaingBeforeBigPlayerOpening = false
                }
            }
            videoContainer.onCloseBigPlayer = {
                if self.isAudioPlayerPlaingBeforeBigPlayerOpening {
                    model.audioPlayer.play()
                }
            }
            videoContainer.snp.removeConstraints()
            videoContainer.snp.makeConstraints {
                $0.top.equalTo(model.contentLabel != nil
                               ? contentLabel.snp.bottom
                               : userImageView.snp.bottom
                ).inset(-8)
                $0.leading.equalTo(contentView.snp.leading)
                $0.trailing.equalTo(contentView.snp.trailing)
                $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                $0.height.equalTo(contentView.snp.width).multipliedBy(0.6)
            }
            audioView.removeFromSuperview()
            contentImageView.removeFromSuperview()
        case .Image(let url):
            guard let url = url else { return }
            contentView.addSubview(contentImageView)
            self.contentImageView.setImageUrl(url: url)
            contentImageView.snp.removeConstraints()
            contentImageView.snp.makeConstraints {
                $0.top.equalTo(model.contentLabel != nil
                               ? contentLabel.snp.bottom
                               : userImageView.snp.bottom
                ).inset(-8)
                $0.leading.equalTo(contentView.snp.leading)
                $0.trailing.equalTo(contentView.snp.trailing)
                $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                $0.height.equalTo(contentImageView.snp.width)
            }
            videoContainer.removeFromSuperview()
            audioView.removeFromSuperview()
        case .Audio(let url):
            guard let url = url else { return }
            contentView.addSubview(audioView)
            audioView.player = model.audioPlayer
            audioView.audioURL = url
            audioView.onItemLoadingError = model.onAudioLoadingError
            audioView.setupPlayerData()
            audioView.snp.removeConstraints()
            audioView.snp.makeConstraints {
                $0.top.equalTo(model.contentLabel != nil
                               ? contentLabel.snp.bottom
                               : userImageView.snp.bottom
                ).inset(-8)
                $0.leading.equalTo(contentView.snp.leading).inset(16)
                $0.trailing.equalTo(contentView.snp.trailing).inset(16)
                $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                $0.height.equalTo(40)
            }
            contentImageView.removeFromSuperview()
            videoContainer.removeFromSuperview()
        case .none:
            videoContainer.snp.removeConstraints()
            contentImageView.snp.removeConstraints()
            audioView.snp.removeConstraints()
            videoContainer.removeFromSuperview()
            contentImageView.removeFromSuperview()
            audioView.removeFromSuperview()
        }
    }
    
    private func setupControlButtonConstraints() {
        shareButton.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(48)
            $0.trailing.equalTo(contentView.snp.trailing).inset(8)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
        
        commentButton.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(48)
            $0.trailing.equalTo(shareButton.snp.leading)
            $0.centerY.equalTo(shareButton.snp.centerY)
        }
        
        likeButton.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(48)
            $0.trailing.equalTo(commentButton.snp.leading)
            $0.centerY.equalTo(shareButton.snp.centerY)
        }
    }
    
    private func setupData(model: Model) {
        
        likeButton.onTap = {
            model.likeButtonTapAction()
        }
        
        commentButton.onTap = {
            model.commentButtonTapAction()
        }
        
        userInfoContainerButton.onTap = {
            model.profileTapAction()
        }
        
        shareButton.onTap = {
            model.shareButtonTapAction()
        }
        
        setupLikes(model.likesModel)
        
        let commentsCount = String(model.commentsCount)
        self.commentButton.setTitle(commentsCount, for: .normal)
        
        self.usernameLabel.text = model.name
        self.userImageView.setImageUrl(url: model.userImageURL)
    }

    func setup(_ model: Model) {
        setupLayout(model: model)
    }
    
    func setupLikes(_ model: LikesModel) {
        let likesCount = String(model.likesCount)
        self.likeButton.setTitle(likesCount, for: .normal)
        
        if model.isLiked {
            likeButton.setImage(UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    public func startVideo() {
        self.videoContainer.play()
    }
    
    public func stopVideo() {
        self.videoContainer.pause()
    }
}
