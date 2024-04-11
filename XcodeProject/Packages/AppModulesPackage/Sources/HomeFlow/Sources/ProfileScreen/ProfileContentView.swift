import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension ProfileViewController {

    final class ContentView: BaseView {

        private(set) lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.register(NewsCell.self, forCellReuseIdentifier: String(describing: NewsCell.self))
            tableView.register(ProfileCell.self, forCellReuseIdentifier: String(describing: ProfileCell.self))
            tableView.separatorStyle = .none
            tableView.bounces = false
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
        
        override func setLayout() {
            addSubview(tableView)
            addSubview(activityIndicator)
            
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
        }
    }
}
