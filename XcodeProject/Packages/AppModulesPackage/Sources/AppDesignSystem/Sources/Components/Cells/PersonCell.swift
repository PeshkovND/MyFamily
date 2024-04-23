import UIKit
import AppEntities
import Utilities

public final class PersonCell: UITableViewCell {
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
    
    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = 56/2
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
    
    private let statusLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.body.withSize(12)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    private let container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .leading
        view.spacing = 4
        view.distribution = .equalSpacing
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(userImageView)
        contentView.addSubview(container)
        container.addArrangedSubview(usernameLabel)
        container.addArrangedSubview(statusLabel)
        
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.width.equalTo(56)
            $0.height.equalTo(56)
            $0.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setup(_ model: Model) {
        self.userImageView.setImageUrl(url: model.userImageURL)
        
        let text = NSMutableAttributedString(string: model.name + " ")
        if model.isPro {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = appDesignSystem.icons.premium
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
