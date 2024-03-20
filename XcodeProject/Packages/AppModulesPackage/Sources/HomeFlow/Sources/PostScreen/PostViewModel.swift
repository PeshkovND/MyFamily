import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class PostViewModel: BaseViewModel<PostViewEvent,
                                               PostViewState,
                                               PostOutputEvent> {
    
    private let strings = appDesignSystem.strings
    var post: NewsViewPost?
    var postId: String
    var comments: [Comment] = []
    var audioPlayer: AVQueuePlayer
    let repository: PostRepository
    
    init(postId: String, audioPlayer: AVQueuePlayer, repository: PostRepository) {
        self.audioPlayer = audioPlayer
        self.postId = postId
        self.repository = repository
        super.init()
    }
    
    override func onViewEvent(_ event: PostViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            self.viewState = .loading
            getPostData()
        case .pullToRefresh:
            self.viewState = .loading
            getPostData()
        case .profileTapped(id: let id):
            outputEventSubject.send(.personCardTapped(id: id))
        case .shareTapped(id: let id):
            outputEventSubject.send(.shareTapped(id: id))
        }
    }
    
    func addComment(text: String, onSuccess: @escaping () -> Void) {
        Task {
            let str = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let postId = UUID(uuidString: postId), !str.isEmpty else { return }
            guard let comment = try await self.repository.addComment(text: text, postId: postId) else {
                return
            }
            self.comments.append(comment)
            
            await MainActor.run {
                self.viewState = .loaded
                onSuccess()
            }
        }
    }
    
    private func getPostData() {
        Task {
            guard let postId = UUID(uuidString: postId) else { return }
            let (post, comments) = try await repository.getPostData(id: postId)
            self.post = post
            self.comments = comments
            
            await MainActor.run {
                self.viewState = .loaded
            }
        }
    }
    
    func likeButtonDidTapped() {
        guard var post = self.post else { return }
        if post.isLiked {
            post.likesCount -= 1
        } else {
            post.likesCount += 1
        }
        post.isLiked.toggle()
        self.post = post
        Task {
            guard let postId = UUID(uuidString: self.post?.id ?? "") else { return }
            try await repository.likeOrUnlikePost(postId: postId)
        }
    }
    
    private func makeScreenError(from appError: AppError) -> PostContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: PostContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: PostContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return PostContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
