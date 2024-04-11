import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension FamilyViewController {

    final class ContentView: BaseView {

        private(set) lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.register(PersonCell.self, forCellReuseIdentifier: String(describing: PersonCell.self))
            tableView.separatorStyle = .none
            return tableView
        }()
        
        private(set) lazy var activityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = .black
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            return activityIndicator
        }()
        
        private(set) lazy var failedStackView: UIStackView = {
                    let view = UIStackView()
                    view.axis = .vertical
                    view.alignment = .center
                    view.spacing = 24
                    view.distribution = .equalSpacing
                    view.alpha = 0
                    return view
                }()
                
        private(set) lazy var loadingErrorTitle: UILabel = {
            let view = UILabel()
            view.font = appDesignSystem.typography.headline
            view.numberOfLines = 0
            view.textAlignment = .center
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "exclamationmark.triangle")?.withTintColor(.red)
            
            let text = NSMutableAttributedString(string: appDesignSystem.strings.contentLoadingErrorTitle + " ")
            text.append(NSAttributedString(attachment: imageAttachment))
            view.attributedText = text
            
            return view
        }()
        
        private(set) lazy var loadingErrorSubtitle: UILabel = {
            let view = UILabel()
            view.font = appDesignSystem.typography.body
            view.numberOfLines = 0
            view.textAlignment = .center
            view.text = appDesignSystem.strings.contentLoadingErrorSubitle
            
            return view
        }()
        
        override func setLayout() {
            addSubview(tableView)
            addSubview(activityIndicator)
            addSubview(failedStackView)
            failedStackView.addArrangedSubview(loadingErrorTitle)
            failedStackView.addArrangedSubview(loadingErrorSubtitle)
            
            tableView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            activityIndicator.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            failedStackView.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.center.equalToSuperview()
            }
        }
    }
}
