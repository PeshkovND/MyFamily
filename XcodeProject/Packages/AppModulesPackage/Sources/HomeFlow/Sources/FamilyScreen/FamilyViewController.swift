import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

struct FamilyViewData {
    let id: Int
    let userImageURL: URL?
    let name: String
    let status: PersonStatus
    let isPro: Bool
}

final class FamilyViewController: BaseViewController<FamilyViewModel,
                                FamilyViewEvent,
                                FamilyViewState,
                                FamilyViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var tableView: UITableView { contentView.tableView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var failedStackView: UIStackView { contentView.failedStackView }
    private var loadingView: UIView { contentView.loadingView }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        refreshControl.tintColor = colors.labelPrimary
        return refreshControl
    }()
    
    private var isLoadingShowing = false {
        willSet {
            UIView.animate {
                loadingView.alpha = newValue ? 1 : 0
            }
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !newValue
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
        loadingView.alpha = 0
    }
    
    override func onViewState(_ viewState: FamilyViewState) {
        switch viewState {
        case .loaded:
            self.isLoadingShowing = false
            showContent()
        case .failed:
            showError()
        case.loading:
            break
        case .initial:
            break
        case let .deleteConfirmation(user):
            showDeleteConfirmationAlert(user: user)
        case .fullscreenLoading:
            self.isLoadingShowing = true
        case .alert(title: let title, subtitle: let subtitle):
            let alert = UIAlertController(
                title: title,
                message: subtitle,
                preferredStyle: .alert
            )
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func showDeleteConfirmationAlert(user: FamilyViewData) {
        let alert = UIAlertController(
            title: "Attention",
            message: "Do you really want to remove user \(user.name) from the family",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Yes",
                style: .default,
                handler: { [weak self] _ in
                    self?.viewModel.onViewEvent(.deleteUserConfirmationTapped(user: user))
                }
            )
        )
        alert.addAction(.cancelAction())
        present(alert, animated: true, completion: nil)
    }
    
    private func showContent() {
        tableView.alpha = 1
        failedStackView.alpha = 0
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    private func showError() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        failedStackView.alpha = 1
    }
    
    private func configureView() {
        if viewModel.isEnoughPermissions {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: appDesignSystem.icons.plus,
                style: .done,
                target: self,
                action: #selector(addUserDidTapped)
            )
        }
        self.contentView.backgroundColor = colors.backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }

    @objc
    private func addUserDidTapped() {
        viewModel.onViewEvent(.addUserTapped)
    }
}

extension FamilyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PersonCell.self), for: indexPath)
        guard let cell = cell as? PersonCell else { return cell }
        let person = viewModel.persons[indexPath.row]
        let model = PersonCell.Model(
            userImageURL: person.userImageURL,
            name: person.name,
            status: person.status,
            isPro: person.isPro,
            onTapDelete: viewModel.isEnoughPermissions ? { [weak self] in
                self?.viewModel.onViewEvent(.deleteUserTapped(id: person.id))
            } : nil
        )
        cell.setup(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = viewModel.persons[indexPath.row]
        viewModel.onViewEvent(.profileTapped(id: person.id))
    }
}

extension FamilyViewController: UITableViewDelegate { }
