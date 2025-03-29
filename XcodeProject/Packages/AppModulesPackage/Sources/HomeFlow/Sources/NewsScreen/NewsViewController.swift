import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit
import MobileCoreServices

struct NewsViewPost {
    let id: String
    let userId: Int
    let userImageURL: URL?
    let name: String
    let contentLabel: String?
    let mediaContent: MediaContent?
    var likesCount: Int
    let commentsCount: Int
    var isLiked: Bool
    let isPremium: Bool
}

final class NewsViewController: BaseViewController<NewsViewModel,
                                NewsViewEvent,
                                NewsViewState,
                                NewsViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var tableView: UITableView { contentView.tableView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var audioLoadingErrorSnackBar: AppSnackBar { contentView.audioLoadingErrorSnackBar }
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
        loadingView.alpha = 0
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: appDesignSystem.icons.plus,
            style: .done,
            target: self,
            action: #selector(addPostButtonDidTapped)
        )
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.onViewEvent(.viewWillAppear)
    }
    
    override func onViewState(_ viewState: NewsViewState) {
        switch viewState {
        case .loaded:
            isLoadingShowing = false
            failedStackView.alpha = 0
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.reloadData()
            tableView.layoutIfNeeded()
        case .failed:
            isLoadingShowing = false
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            failedStackView.alpha = 1
        case .initial:
            isLoadingShowing = false
            failedStackView.alpha = 0
            tableView.reloadData()
            tableView.layoutIfNeeded()
            activityIndicator.startAnimating()
            refreshControl.endRefreshing()
            break
        case .loading:
            isLoadingShowing = false
            break
        case .fullscreenLoading:
            isLoadingShowing = true
        case .alert(title: let title, subtitle: let subtitle):
            isLoadingShowing = false
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addAction(.closeAction())
            present(alert, animated: true)
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func addPostButtonDidTapped() {
        viewModel.onViewEvent(.addPostTapped)
    }
    
    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NewsCell.self), for: indexPath)
        guard let cell = cell as? NewsCell else { return cell }
        let post = viewModel.posts[indexPath.row]
        let model = NewsCell.Model(
            userImageURL: post.userImageURL,
            name: post.name,
            contentLabel: post.contentLabel,
            mediaContent: post.mediaContent,
            commentsCount: post.commentsCount,
            likeButtonTapAction: {
                self.viewModel.likeButtonDidTappedOn(post: self.viewModel.posts[indexPath.row], at: indexPath.row)
                let postModel = self.viewModel.posts[indexPath.row]
                let model = NewsCell.LikesModel(likesCount: postModel.likesCount, isLiked: postModel.isLiked)
                cell.setupLikes(model)
            },
            profileTapAction: { self.viewModel.onViewEvent(.userTapped(id: post.userId)) },
            commentButtonTapAction: { self.viewModel.onViewEvent(.commentTapped(id: post.id)) },
            shareButtonTapAction: { self.viewModel.onViewEvent(.shareTapped(id: post.id)) },
            onAudioLoadingError: { self.audioLoadingErrorSnackBar.showIn(view: self.view) },
            isPremium: post.isPremium,
            likesModel: NewsCell.LikesModel(
                likesCount: post.likesCount,
                isLiked: post.isLiked
            ),
            audioPlayer: viewModel.audioPlayer,
            moreButtonMenu: {
                if post.userId == viewModel.currentUserId {
                    let deleteAction = UIAction(
                        title: "Delete",
                        image: appDesignSystem.icons.trash) { [weak self] _ in
                            self?.viewModel.onViewEvent(.deletePostTapped(id: post.id))
                        }
                    return UIMenu(options: .displayInline, children: [deleteAction])
                }
                return nil
            }()
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

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        switch viewModel.posts[indexPath.row].mediaContent {
        case .Video:
            cell.startVideo()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NewsCell else { return }
        if indexPath.row < viewModel.posts.count {
            switch viewModel.posts[indexPath.row].mediaContent {
            case .Video:
                cell.stopVideo()
            default:
                break
            }
        }
    }
}
