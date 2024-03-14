import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

struct Comment {
    let userId: String
    let username: String
    let imageUrl: URL?
    let text: String
}

final class PostViewController: BaseViewController<PostViewModel,
                                PostViewEvent,
                                PostViewState,
                                PostViewController.ContentView> {
    
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
    
    override func onViewState(_ viewState: PostViewState) {
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

extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = viewModel.post  else { return 0 }
        let count = section == 0 ? 1 : viewModel.comments.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return makePostCell(tableView: tableView, cellForRowAt: indexPath)
        } else {
            return makeCommentCell(tableView: tableView, cellForRowAt: indexPath)
        }
    }
    
    private func makePostCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NewsCell.self), for: indexPath
        )
        guard let cell = cell as? NewsCell,
              let post = viewModel.post else { return cell }
        let model = NewsCell.Model(
            userImageURL: post.userImageURL,
            name: post.name,
            contentLabel: post.contentLabel,
            mediaContent: post.mediaContent,
            commentsCount: post.commentsCount,
            likeButtonTapAction: {
                self.viewModel.likeButtonDidTapped()
                let model = NewsCell.LikesModel(
                    likesCount: self.viewModel.post?.likesCount ?? 0,
                    isLiked: self.viewModel.post?.isLiked ?? false
                )
                cell.setupLikes(model)
            },
            profileTapAction: { self.viewModel.onViewEvent(.profileTapped(id: post.userId)) },
            commentButtonTapAction: { },
            shareButtonTapAction: { self.viewModel.onViewEvent(.shareTapped(id: post.id)) },
            likesModel: NewsCell.LikesModel(
                likesCount: post.likesCount,
                isLiked: post.isLiked
            ),
            audioPlayer: viewModel.audioPlayer
        )
        cell.setup(model)
        return cell
    }
    
    func makeCommentCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: CommentCell.self), for: indexPath
        )
        guard let cell = cell as? CommentCell else { return cell }
        let comment = viewModel.comments[indexPath.row]
        let model = CommentCell.Model(
            userImageURL: comment.imageUrl,
            name: comment.username,
            text: comment.text,
            userTapAction: { self.viewModel.onViewEvent(.profileTapped(id: comment.userId)) }
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
        guard let _ = viewModel.post else { return 0 }
        return 2
    }
}

extension PostViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        cell.startVideo()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        cell.stopVideo()
    }
}
