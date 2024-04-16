import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

struct Comment {
    let userId: Int
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
    private var textView: UITextView { contentView.textView }
    private var textContainer: UIView { contentView.textContainer }
    private var audioLoadingErrorSnackBar: AppSnackBar { contentView.audioLoadingErrorSnackBar }
    private var failedStackView: UIStackView { contentView.failedStackView }
    private var sendButton: ActionButton { contentView.sendButton }
    private var addCommentActivityIndicator: UIActivityIndicatorView { contentView.addCommentActivityIndicator }
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeKeyboard()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            textContainer.snp.removeConstraints()
            textContainer.snp.updateConstraints {
                $0.bottom.equalTo(view.snp.bottom).inset(keyboardSize.height - 1)
                $0.leading.equalToSuperview().inset(-1)
                $0.trailing.equalToSuperview().inset(-1)
                $0.height.equalTo(64)
            }
        }
    }
    
    @objc func  keyboardWillHide(_ notification: Notification) {
        textContainer.snp.removeConstraints()
        textContainer.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(-1)
            $0.leading.equalToSuperview().inset(-1)
            $0.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(64)
        }
    }
    
    override func onViewState(_ viewState: PostViewState) {
        switch viewState {
        case .loaded:
            failedStackView.alpha = 0
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.reloadData()
            tableView.layoutIfNeeded()
            textContainer.alpha = 1
            sendButton.alpha = 1
            addCommentActivityIndicator.stopAnimating()
        case .loading:
            textContainer.alpha = 0
        case .failed:
            failedStackView.alpha = 1
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        case .initial:
            break
        case .addCommentLoading:
            addCommentActivityIndicator.startAnimating()
            sendButton.alpha = 0
        case .addCommentFailed:
            sendButton.alpha = 1
            addCommentActivityIndicator.stopAnimating()
            let alert = UIAlertController(
                title: appDesignSystem.strings.postAddCommentErrorTitle,
                message: appDesignSystem.strings.postAddCommentErrorSubtitle,
                preferredStyle: .alert
            )
            alert.addAction(.cancelAction())
            self.present(alert, animated: true)
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        viewModel.onViewEvent(.viewDidLoad)
        textView.delegate = self
        tabBarController?.tabBar.backgroundColor = colors.backgroundPrimary
        
        let tableGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        tableView.addGestureRecognizer(tableGesture)
        
        sendButton.onTap = {
            if self.textView.textColor != UIColor.lightGray {
                self.viewModel.addComment(text: self.textView.text) {
                    self.textView.text = nil
                    self.textViewDidEndEditing(self.textView)
                    self.textView.resignFirstResponder()
                    let indexPath = IndexPath(row: self.viewModel.comments.count-1, section: 1)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }

        }
    }
    
    @objc
    private func closeKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }
}

extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel.post != nil  else { return 0 }
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
            onAudioLoadingError: { self.audioLoadingErrorSnackBar.showIn(view: self.view) },
            isPremium: post.isPremium,
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
        guard viewModel.post != nil else { return 0 }
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

extension PostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = appDesignSystem.strings.postScreenCommentPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}
