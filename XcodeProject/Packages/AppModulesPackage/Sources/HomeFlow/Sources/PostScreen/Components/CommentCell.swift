import UIKit
import AppDesignSystem

final class CommentCell: UITableViewCell {
    struct Model {
        let userImageURL: URL?
        let name: String
        let text: String
        let userTapAction: () -> Void
    }
    
    private let userImageView: UIImageView = {
        let userImageView = UIImageView()
        userImageView.layer.cornerRadius = 40/2
        userImageView.clipsToBounds = true
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.contentMode = .scaleAspectFill
        return userImageView
    }()
    
    private let userImageButtonContainer: ActionButton = {
        let view = ActionButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.backgroundSecondaryVariant
        usernameLabel.font = appDesignSystem.typography.body.withSize(16)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    private let usernameButtonContainer: ActionButton = {
        let view = ActionButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let commentLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.body.withSize(16)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(userImageButtonContainer)
        contentView.addSubview(usernameButtonContainer)
        userImageButtonContainer.addSubview(userImageView)
        usernameButtonContainer.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
        
        userImageButtonContainer.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.width.equalTo(40)
            $0.height.equalTo(40)
            $0.top.equalTo(contentView.snp.top).inset(8)
        }
        
        userImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        usernameButtonContainer.snp.makeConstraints {
            $0.leading.equalTo(userImageButtonContainer.snp.trailing).inset(-8)
            $0.top.equalTo(contentView.snp.top)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).inset(-8)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
            $0.top.equalTo(usernameLabel.snp.bottom)
            $0.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(_ model: Model) {
        self.usernameLabel.text = model.name
        self.userImageView.setImageUrl(url: model.userImageURL)
        self.commentLabel.text = model.text
        
        self.usernameButtonContainer.onTap = model.userTapAction
        self.userImageButtonContainer.onTap = model.userTapAction
    }
}
