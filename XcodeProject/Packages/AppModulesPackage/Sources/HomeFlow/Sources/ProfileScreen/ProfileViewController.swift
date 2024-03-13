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
        default: break
        }
    }
    
    private func configureView() {
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
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.profile?.posts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                self.viewModel.likeButtonDidTappedOn(post: post, at: indexPath.row)
                guard let postModel = self.viewModel.profile?.posts[indexPath.row] else { return }
                let model = NewsCell.LikesModel(likesCount: postModel.likesCount, isLiked: postModel.isLiked)
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
