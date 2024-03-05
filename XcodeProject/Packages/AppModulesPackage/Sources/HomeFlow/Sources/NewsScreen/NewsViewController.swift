import Foundation

//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

struct NewsViewPost: Hashable {
    let userImageURL: URL?
    let name: String
    let contentLabel: String?
    let contentImageURL: URL?
    let contentVideoURL: URL?
    let contentAudioURL: URL?
    var likesCount: Int
    let commentsCount: Int
    var isLiked: Bool
}

final class NewsViewController: BaseViewController<NewsViewModel,
                                NewsViewEvent,
                                NewsViewState,
                                NewsViewController.ContentView> {
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus")?.withTintColor(colors.backgroundSecondaryVariant, renderingMode: .alwaysOriginal),
            style: .done,
            target: self,
            action: #selector(addPostButtonDidTapped)
        )
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: NewsViewState) {
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
            contentImageURL: post.contentImageURL,
            contentVideoURL: post.contentVideoURL,
            contentAudioURL: post.contentAudioURL,
            commentsCount: post.commentsCount,
            likeButtonTapped: {
                self.viewModel.likeButtonDidTappedOn(post: self.viewModel.posts[indexPath.row], at: indexPath.row)
                let postModel = self.viewModel.posts[indexPath.row]
                let model = NewsCell.LikesModel(likesCount: postModel.likesCount, isLiked: postModel.isLiked)
                cell.setupLikes(model)
            },
            commentButtonTapped: { },
            likesModel: NewsCell.LikesModel(
                likesCount: post.likesCount,
                isLiked: post.isLiked
            )
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
    
}
