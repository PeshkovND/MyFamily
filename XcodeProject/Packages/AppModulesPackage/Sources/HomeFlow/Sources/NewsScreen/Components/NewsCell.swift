//  
import UIKit
import Foundation
import Utilities
import AppDesignSystem

final class NewsCell: UITableViewCell {
    
    struct Model {
        let userImageURL: URL?
        let name: String
        let contentImageURL: URL?
        let contentVideoURL: URL?
        let contentAudioURL: URL?
    }
    
    private enum Layout {
        static let cardLabelConstraintValue = CGFloat(16)
        static let containerWidthMultiplier = CGFloat(0.8)
    }
    
    private let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        userImageView.clipsToBounds = true
        return userImageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupLayout() {
        contentView.addSubview(container)
        container.addSubview(userImageView)
        container.addSubview(usernameLabel)
        container.addSubview(contentImageView)
        
        container.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.bottom.equalTo(contentView.snp.bottom)
            $0.left.equalTo(contentView.snp.left)
            $0.right.equalTo(contentView.snp.right)
        }
        
        userImageView.snp.makeConstraints {
            $0.leading.equalTo(container.snp.leading).inset(16)
            $0.top.equalTo(container.snp.top).inset(16)
            $0.width.equalTo(48)
            $0.height.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.centerY.equalTo(userImageView.snp.centerY).inset(16)
            $0.trailing.equalTo(container.snp.trailing).inset(8)
        }

        contentImageView.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.bottom).inset(-8)
            $0.width.equalTo(container.snp.width).inset(16)
            $0.centerX.equalTo(container.snp.centerX)
            $0.bottom.equalTo(container.snp.bottom)
        }
    }
    
    func setup(_ model: Model) {
        self.contentImageView.setImageUrl(url: model.contentImageURL)
        self.usernameLabel.text = model.name
        self.userImageView.setImageUrl(url: model.userImageURL)
    }
}
