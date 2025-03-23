import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

final class FamilyInvitationViewController: BaseViewController<FamilyInvitationViewModel,
                                FamilyInvitationViewEvent,
                                FamilyInvitationViewState,
                                FamilyInvitationViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    private var tableView: UITableView { contentView.tableView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var failedStackView: UIStackView { contentView.failedStackView }
    private var loadingView: UIView { contentView.loadingView }
    private lazy var backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backTapped))
    
    private var isLoadingShowing = false {
        willSet {
            UIView.animate {
                loadingView.alpha = newValue ? 1 : 0
            }
            self.backButton.isEnabled = !newValue
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !newValue
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        refreshControl.tintColor = colors.labelPrimary
        return refreshControl
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.alpha = 1
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onViewEvent(.viewDidAppear)
    }
    
    override func onViewState(_ viewState: FamilyInvitationViewState) {
        switch viewState {
        case .loaded:
            isLoadingShowing = false
            showContent()
        case .failed:
            isLoadingShowing = false
            showError()
        case.loading:
            isLoadingShowing = true
        case .initial:
            break
        case .alert(title: let title, subtitle: let subtitle):
            isLoadingShowing = false
            let alert = UIAlertController(
                title: title,
                message: subtitle,
                preferredStyle: .alert
            )
            alert.addAction(.cancelAction())
            self.present(alert, animated: true)
        }
    }
    
    @objc private func backTapped() {
        viewModel.onViewEvent(.backTapped)
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
        title = appDesignSystem.strings.invitationsScreenTitle
        navigationItem.backButtonTitle = ""
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: appDesignSystem.icons.plus,
            style: .done,
            target: self,
            action: #selector(addCodeDidTapped)
        )
        self.contentView.backgroundColor = colors.backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func addCodeDidTapped() {
        viewModel.onViewEvent(.addCodeTapped)
    }

    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }
}

extension FamilyInvitationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.invitations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: InviteCodeCell.self), for: indexPath)
        guard let cell = cell as? InviteCodeCell else { return cell }
        let invitation = viewModel.invitations[indexPath.row]
        let model = InviteCodeCell.Model(
            code: invitation.id,
            creationDate: invitation.dateCreated,
            onCopy: { [weak self] code in self?.viewModel.onViewEvent(.copyCodeTapped(id: code)) },
            onDelete: { [weak self] code in self?.viewModel.onViewEvent(.deleteCodeTapped(id: code)) }
        )
        cell.setup(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
}

extension FamilyInvitationViewController: UITableViewDelegate { }
