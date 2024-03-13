import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

struct Profile {
    let id: String
    let userImageURL: URL?
    let name: String
    let status: PersonStatus
    var posts: [NewsViewPost]
}

final class ProfileViewController: BaseViewController<ProfileViewModel,
                                ProfileViewEvent,
                                ProfileViewState,
                                ProfileViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var tableView: UITableView { contentView.tableView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        refreshControl.tintColor = colors.labelPrimary
        return refreshControl
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: ProfileViewState) {
        switch viewState {
        case .loaded:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.reloadData()
            tableView.layoutIfNeeded()
            setupEditProfileButton()
            
        default: break
        }
    }
    
    @objc
    private func editProfileTapped() {}
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    private func setupEditProfileButton() {
        if viewModel.isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "pencil")?.withTintColor(colors.backgroundSecondaryVariant, renderingMode: .alwaysOriginal),
                style: .done,
                target: self,
                action: #selector(editProfileTapped)
            )
        }
    }

    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.profile?.posts.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0
        ? createProfileCell(tableView, cellForRowAt: indexPath)
        : createPostCell(tableView, cellForRowAt: indexPath)
    }
    
    private func createProfileCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ProfileCell.self),
            for: indexPath
        )
        guard let cell = cell as? ProfileCell else { return cell }
        guard let profile = viewModel.profile else { return UITableViewCell() }
        let model = ProfileCell.Model(
            userImageURL: profile.userImageURL,
            name: profile.name,
            status: profile.status
        )
        cell.setup(model)
        return cell
    }
    
    private func createPostCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NewsCell.self), for: indexPath)
        guard let cell = cell as? NewsCell else { return cell }
        guard let post = viewModel.profile?.posts[indexPath.row] else { return UITableViewCell() }
        let model = NewsCell.Model(
            userImageURL: post.userImageURL,
            name: post.name,
            contentLabel: post.contentLabel,
            mediaContent: post.mediaContent,
            commentsCount: post.commentsCount,
            likeButtonTapped: {
                self.viewModel.likeButtonDidTappedOn(post: self.viewModel.profile?.posts[indexPath.row], at: indexPath.row)
                let postModel = self.viewModel.profile?.posts[indexPath.row]
                let model = NewsCell.LikesModel(likesCount: postModel?.likesCount ?? 0, isLiked: postModel?.isLiked ?? false)
                cell.setupLikes(model)
            },
            commentButtonTapped: { },
            likesModel: NewsCell.LikesModel(
                likesCount: post.likesCount,
                isLiked: post.isLiked
            ),
            audioPlayer: viewModel.audioPlayer
        )
        cell.setup(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        cell.startVideo()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        cell.stopVideo()
    }
}
