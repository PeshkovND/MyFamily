import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class NewsViewModel: BaseViewModel<NewsViewEvent,
                                               NewsViewState,
                                               NewsOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private let repository: NewsRepository
    var audioPlayer: AVPlayer
    var posts: [NewsViewPost] = []
    
    init(audioPlayer: AVPlayer, repository: NewsRepository) {
        self.audioPlayer = audioPlayer
        self.repository = repository
        super.init()
    }
    
    func likeButtonDidTappedOn(post: NewsViewPost, at index: Int) {
        var postItem = post
        if postItem.isLiked {
            postItem.likesCount -= 1
        } else {
            postItem.likesCount += 1
        }
        postItem.isLiked.toggle()
        Task {
            guard let postId = UUID(uuidString: post.id) else { return }
            try await repository.likeOrUnlikePost(postId: postId)
        }
        posts[index] = postItem
    }

    override func onViewEvent(_ event: NewsViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            viewState = .initial
            Task { await getPosts() }
        case .addPostTapped:
            outputEventSubject.send(.addPost)
        case .pullToRefresh:
            Task { await getPosts() }
        case .userTapped(id: let id):
            outputEventSubject.send(.openUserProfile(id: id))
        case .commentTapped(id: let id):
            outputEventSubject.send(.commentTapped(id: id))
        case .shareTapped(id: let id):
            outputEventSubject.send(.shareTapped(id: id))
        }
    }
    
    private func getPosts() async {
        do {
            let posts = try await repository.getPosts()
            self.posts = posts
            await MainActor.run {
                self.viewState = .loaded(content: posts)
            }
        } catch {
            await MainActor.run {
                self.viewState = .failed(
                    error: self.makeScreenError(
                        from: .custom(
                            title: self.strings.contentLoadingErrorTitle,
                            message: self.strings.contentLoadingErrorSubitle
                        )
                    )
                )
            }
        }
    }

    private func makeScreenError(from appError: AppError) -> NewsContext.ScreenError? {
        switch appError {
        case .network:
            let screenError: NewsContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return NewsContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
