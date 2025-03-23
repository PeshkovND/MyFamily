import UIKit
import AppEntities
import Utilities

public final class InviteCodeCell: UITableViewCell {
    public struct Model {
        let code: String
        let creationDate: String
        let onCopy: (String) -> Void
        let onDelete: (String) -> Void
        
        public init(code: String, creationDate: String, onCopy: @escaping (String) -> Void, onDelete: @escaping (String) -> Void) {
            self.code = code
            self.creationDate = creationDate
            self.onCopy = onCopy
            self.onDelete = onDelete
        }
    }
    
    private let codeLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.labelPrimary
        usernameLabel.font = appDesignSystem.typography.body.withSize(16)
        usernameLabel.numberOfLines = 0
        return usernameLabel
    }()
    
    private let dateLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.textColor = appDesignSystem.colors.backgroundSecondaryVariant
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
    
    private let copyButton: ActionButton = {
        var filled = UIButton.Configuration.borderless()
        filled.imagePlacement = .leading
        filled.imagePadding = 4
        filled.baseForegroundColor = appDesignSystem.colors.backgroundSecondaryVariant
        
        let button = ActionButton(configuration: filled, primaryAction: nil)
        let icon = UIImage(systemName: "document.on.document")
        button.setImage(icon, for: .normal)
        return button
    }()
    
    private let deleteButton: ActionButton = {
        var filled = UIButton.Configuration.borderless()
        filled.imagePlacement = .leading
        filled.imagePadding = 4
        filled.baseForegroundColor = .red
        
        let button = ActionButton(configuration: filled, primaryAction: nil)
        let icon = UIImage(systemName: "trash")
        button.setImage(icon, for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(container)
        container.addArrangedSubview(codeLabel)
        container.addArrangedSubview(dateLabel)
        contentView.addSubview(copyButton)
        contentView.addSubview(deleteButton)
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(contentView.snp.trailing).inset(16)
            $0.centerY.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading)
            $0.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).inset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(copyButton.snp.leading).inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setup(_ model: Model) {
        codeLabel.text = model.code
        dateLabel.text = model.creationDate
        
        copyButton.onTap = { model.onCopy(model.code) }
        deleteButton.onTap = { model.onDelete(model.code) }
    }
}
