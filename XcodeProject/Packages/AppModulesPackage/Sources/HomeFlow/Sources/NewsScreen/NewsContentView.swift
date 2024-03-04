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
            tableView.backgroundColor = colors.backgroundPrimary
            return tableView
        }()
        
        // swiftlint:disable function_body_length
        override func setLayout() {
            addSubview(tableView)
            
            tableView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
        }
        // swiftlint:enable function_body_length
    }
}
