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
}

final class NewsViewController: BaseViewController<NewsViewModel,
                                                               NewsViewEvent,
                                                               NewsViewState,
                                                               NewsViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper

    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var tableView: UITableView { contentView.tableView }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: NewsViewState) {
        switch viewState {
        case .loaded: 
            tableView.reloadData()
        default: break
        }
    }
    
    private func configureView() {
        tableView.dataSource = self
        tableView.delegate = self
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
                            contentAudioURL: post.contentAudioURL
                        )
        cell.setup(model) { tableView.reloadRows(at: [indexPath], with: .automatic) }
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
