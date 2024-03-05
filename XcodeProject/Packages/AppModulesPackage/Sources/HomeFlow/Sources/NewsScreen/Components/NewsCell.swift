//  
import UIKit
import Foundation
import Utilities
import AppDesignSystem

final class NewsCell: UITableViewCell {
    
    struct Model {
        let userImageURL: URL?
        let name: String
        let contentLabel: String?
        let contentImageURL: URL?
        let contentVideoURL: URL?
        let contentAudioURL: URL?
        var commentsCount: Int
        let likeButtonTapped: () -> Void
        let commentButtonTapped: () -> Void
        
        let likesModel: LikesModel
    }
    
    struct LikesModel {
        var likesCount: Int
        var isLiked: Bool
    }

    private enum Layout {
        static let cardLabelConstraintValue = CGFloat(16)
        static let containerWidthMultiplier = CGFloat(0.8)
    }

    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = 48/2
        userImageView.clipsToBounds = true
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        return userImageView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.subheadline
        usernameLabel.numberOfLines = 0
        return usernameLabel
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
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = appDesignSystem.colors.labelPrimary
        label.font = appDesignSystem.typography.body
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // swiftlint:disable function_body_length
    private func setupLayout(model: Model) {
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(contentImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        
        setupUserInfoConstraints()
        setupContentConstraints(model: model)
        setupControlButtonConstraints()
        
        setupData(model: model)
    }
    
    private func setupUserInfoConstraints() {
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(8)
            $0.top.equalTo(contentView.snp.top).inset(8)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.centerY.equalTo(userImageView.snp.centerY).inset(8)
            $0.trailing.equalTo(contentView.snp.trailing).inset(8)
        }
    }
    
    private func setupContentConstraints(model: Model) {
        if let contentURL = model.contentImageURL {
            
            contentImageView.snp.makeConstraints {
                $0.top.equalTo(model.contentLabel != nil
                               ? contentLabel.snp.bottom
                               : userImageView.snp.bottom
                ).inset(-8)
                $0.leading.equalTo(contentView.snp.leading).inset(8)
                $0.trailing.equalTo(contentView.snp.trailing).inset(8)
                $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                $0.height.equalTo(contentImageView.snp.width)
            }
            
            self.contentImageView.setImageUrl(url: contentURL)
        }
        
        if let contentText = model.contentLabel {
            contentLabel.text = contentText
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(userImageView.snp.bottom).inset(-8)
                $0.leading.equalTo(contentView.snp.leading).inset(8)
                $0.trailing.equalTo(contentView.snp.trailing).inset(8)
                if model.contentImageURL == nil {
                    $0.bottom.equalTo(commentButton.snp.top).inset(-8)
                }
            }
        }
    }
    
    private func setupControlButtonConstraints() {
        shareButton.snp.makeConstraints {
            $0.trailing.equalTo(contentView.snp.trailing).inset(8)
            $0.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
        
        commentButton.snp.makeConstraints {
            $0.trailing.equalTo(shareButton.snp.leading).inset(8)
            $0.centerY.equalTo(shareButton.snp.centerY)
        }
        
        likeButton.snp.makeConstraints {
            $0.trailing.equalTo(commentButton.snp.leading).inset(8)
            $0.centerY.equalTo(shareButton.snp.centerY)
        }
    }
    
    private func setupData(model: Model) {
        
        likeButton.onTap = {
            model.likeButtonTapped()
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
}
