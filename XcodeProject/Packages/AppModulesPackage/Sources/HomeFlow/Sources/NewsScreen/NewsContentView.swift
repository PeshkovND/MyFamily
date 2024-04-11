import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension NewsViewController {

    final class ContentView: BaseView {

        private(set) lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.register(NewsCell.self, forCellReuseIdentifier: String(describing: NewsCell.self))
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
            addSubview(tableView)
            addSubview(activityIndicator)
            addSubview(failedStackView)

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
