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
    
    private let contentImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        return userImageView
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
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(contentImageView)
        contentView.addSubview(contentLabel)
        
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.top.equalTo(contentView.snp.top).inset(16)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.centerY.equalTo(userImageView.snp.centerY).inset(16)
            $0.trailing.equalTo(contentView.snp.trailing).inset(8)
        }
    }

    func setup(_ model: Model, complition: @escaping()->Void) {
        if let contentURL = model.contentImageURL {
            
            contentImageView.snp.makeConstraints {
                $0.top.equalTo(model.contentLabel != nil
                               ? contentLabel.snp.bottom
                               : userImageView.snp.bottom
                ).inset(-8)
                $0.leading.equalTo(contentView.snp.leading)
                $0.trailing.equalTo(contentView.snp.trailing)
                $0.bottom.equalTo(contentView.snp.bottom)
                $0.height.equalTo(contentImageView.snp.width)
            }
            
            self.contentImageView.setImageUrl(url: contentURL)
        }
        
        if let contentText = model.contentLabel {
            contentLabel.text = contentText
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(userImageView.snp.bottom).inset(-8)
                $0.leading.equalTo(contentView.snp.leading)
                $0.trailing.equalTo(contentView.snp.trailing)
                if model.contentImageURL == nil {
                    $0.bottom.equalTo(contentView.snp.bottom)
                }
            }
        }
        
        self.usernameLabel.text = model.name
        self.userImageView.setImageUrl(url: model.userImageURL)
        complition()
    }
}
