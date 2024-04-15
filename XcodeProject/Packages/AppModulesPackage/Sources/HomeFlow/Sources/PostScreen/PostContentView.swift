import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension PostViewController {

    final class ContentView: BaseView {

        private(set) lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.register(NewsCell.self, forCellReuseIdentifier: String(describing: NewsCell.self))
            tableView.register(CommentCell.self, forCellReuseIdentifier: String(describing: CommentCell.self))
            tableView.separatorStyle = .none
            return tableView
        }()
        
        private(set) lazy var textView: UITextView = {
            let view = UITextView()
            view.font = appDesignSystem.typography.body.withSize(16)
            view.tintColor = colors.backgroundSecondaryVariant
            view.translatesAutoresizingMaskIntoConstraints = true
            view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            view.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            view.text = strings.postScreenCommentPlaceholder
            view.textColor = UIColor.lightGray
            
            return view
        }()
        
        private(set) lazy var sendButton: ActionButton = {
            let view = ActionButton()
            var image = UIImage(systemName: "arrow.forward.circle")?.withTintColor(
                colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            ).scaleImageToFitSize(
                size: .init(
                    width: 36,
                    height: 36
                )
            )
            view.setImage(image, for: .normal)
            
            return view
        }()
        
        private(set) lazy var textContainer: UIView = {
            let view = UIView()
            view.backgroundColor = colors.backgroundPrimary
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
            return view
        }()
        
        private(set) lazy var activityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = .black
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            return activityIndicator
        }()
        
        private(set) lazy var audioLoadingErrorSnackBar: AppSnackBar = {
            return AppSnackBar(text: appDesignSystem.strings.postAudioLoadingError)
        }()
        
        private(set) lazy var failedStackView: UIStackView = {
            return FailedStackView(
                title: appDesignSystem.strings.contentLoadingErrorTitle,
                subtitle: appDesignSystem.strings.contentLoadingErrorSubitle
            )
        }()
        
        override func setLayout() {
            addSubview(textContainer)
            addSubview(failedStackView)
            textContainer.addSubview(textView)
            textContainer.addSubview(sendButton)
            addSubview(tableView)
            addSubview(activityIndicator)
            
            tableView.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.bottom.equalTo(textContainer.snp.top)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            activityIndicator.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            textContainer.snp.makeConstraints{
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(-1)
                $0.leading.equalToSuperview().inset(-1)
                $0.trailing.equalToSuperview().inset(-1)
                $0.height.equalTo(60)
            }
            
            sendButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(4)
                $0.height.equalTo(54)
                $0.width.equalTo(54)
            }
            
            textView.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().inset(16)
                $0.trailing.equalTo(sendButton.snp.leading).inset(-16)
            }
            
            failedStackView.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.center.equalToSuperview()
            }
        }
    }
}
