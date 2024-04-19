//
import UIKit
import Foundation
import Utilities
import AppEntities

public final class ProfileCell: UITableViewCell {
    
    public struct Model {
        public let userImageURL: URL?
        public let name: String
        public let status: PersonStatus
        public let isPro: Bool
        
        public init(userImageURL: URL?, name: String, status: PersonStatus, isPro: Bool) {
            self.userImageURL = userImageURL
            self.name = name
            self.status = status
            self.isPro = isPro
        }
    }
    
    private enum Layout {
        static let cardLabelConstraintValue = CGFloat(16)
        static let containerWidthMultiplier = CGFloat(0.8)
    }

    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = 72/2
        userImageView.clipsToBounds = true
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderWidth = 4
        userImageView.layer.borderColor = appDesignSystem.colors.backgroundPrimary.cgColor
        return userImageView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = appDesignSystem.typography.body.withSize(20)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = appDesignSystem.icons.profileBackground
        view.clipsToBounds = true
        return view
    }()
    
    private let downContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = appDesignSystem.colors.backgroundPrimary
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(downContainer)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(statusLabel)
        setupUserInfoConstraints()
    }
    
    private let statusLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.body.withSize(12)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private func setupUserInfoConstraints() {
        
        downContainer.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom)
            $0.top.equalTo(backgroundImageView.snp.bottom).inset(32)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
        }
        
        userImageView.snp.makeConstraints {
            $0.centerY.equalTo(downContainer.snp.top).inset(4)
            $0.centerX.equalTo(backgroundImageView.snp.centerX)
            $0.width.equalTo(72)
            $0.height.equalTo(72)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.bottom).inset(-8)
            $0.centerX.equalTo(userImageView.snp.centerX)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(usernameLabel.snp.bottom).inset(-4)
            $0.centerX.equalTo(userImageView.snp.centerX)
            $0.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(182)
        }
    }

    public func setup(_ model: Model) {
        userImageView.setImageUrl(url: model.userImageURL)
        
        let text = NSMutableAttributedString(string: model.name + " ")
        if model.isPro {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "crown")?.withTintColor(appDesignSystem.colors.premiumColor)
            text.append(NSAttributedString(attachment: imageAttachment))
        }
        
        usernameLabel.attributedText = text
        usernameLabel.textColor = model.isPro
        ? appDesignSystem.colors.premiumColor
        : appDesignSystem.colors.labelPrimary
        
        switch model.status {
        case .online:
            statusLabel.text = appDesignSystem.strings.statusOnlineTitle
            statusLabel.textColor = appDesignSystem.colors.onlineStatusColor
        case .offline(let str):
            statusLabel.text = "\(appDesignSystem.strings.statusOfflineTitle) \(str)"
            statusLabel.textColor = appDesignSystem.colors.offlineStatusColor
        case .atHome:
            statusLabel.text = appDesignSystem.strings.statusAtHomeTitle
            statusLabel.textColor = appDesignSystem.colors.atHomeStatusColor
        }
    }
}
