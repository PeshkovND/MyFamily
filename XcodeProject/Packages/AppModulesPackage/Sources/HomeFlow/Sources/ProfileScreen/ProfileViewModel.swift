import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class ProfileViewModel: BaseViewModel<ProfileViewEvent,
                              ProfileViewState,
                              ProfileOutputEvent> {
    
    var profile: Profile?
    private let strings = appDesignSystem.strings
    private let userId: Int
    private let repository: ProfileRepository
    private let defaultsStorage: DefaultsStorage
    var audioPlayer: AVPlayer
    
    init(userId: Int, audioPlayer: AVPlayer, repository: ProfileRepository,  defaultsStorage: DefaultsStorage) {
        self.audioPlayer = audioPlayer
        self.userId = userId
        self.repository = repository
        self.defaultsStorage = defaultsStorage
        super.init()
    }
    
    func likeButtonDidTappedOn(post: NewsViewPost?, at index: Int) {
        guard var postItem = post else { return }
        if postItem.isLiked {
            postItem.likesCount -= 1
        } else {
            postItem.likesCount += 1
        }
        postItem.isLiked.toggle()
        profile?.posts[index] = postItem
    }
    
    func isCurrentUser() -> Bool {
        guard let id = profile?.id else { return false }
        return repository.isCurrentUser(id: id)
    }
    
    var needShowLeavefamilyButton: Bool {
        guard let id = profile?.id else { return false }
        return repository.isCurrentUser(id: id) && repository.isOwner() == false
    }
    
    override func onViewEvent(_ event: ProfileViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            viewState = .initial
            Task { await getProfile() }
        case .pullToRefresh:
            Task { await getProfile() }
        case .commentTapped(id: let id):
            outputEventSubject.send(.commentTapped(id: id))
        case .shareTapped(id: let id):
            outputEventSubject.send(.shareTapped(id: id))
        case .signOut:
            outputEventSubject.send(.signOut)
        case .editProfileTapped:
            outputEventSubject.send(.editProfile)
        case .getProTapped:
            outputEventSubject.send(.getPro)
        case .leaveFamilyTapped:
            viewState = .fullscreenLoading
            removeFamily()
        case .deletePostTapped(id: let id):
            viewState = .fullscreenLoading
            deletePost(id: id)
        case .viewWillAppear:
            let needUpdatePosts: Bool?
            needUpdatePosts = defaultsStorage.primitiveValue(forKey: "needUpdatePostsInProfile")
            if needUpdatePosts == true {
                self.profile?.posts = []
                viewState = .initial
                Task { await getProfile() }
            }
        }
    }
    
    private func removeFamily() {
        Task {
            do {
                try await repository.removeFamily()
                await MainActor.run {
                    self.outputEventSubject.send(.deleteFamily)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .alert(title: "Error", subtitle: "Please, try again")
                }
            }
        }
    }
    
    
    private func deletePost(id: String) {
        Task {
            do {
                try await repository.deletePost(id: id)
                if let posts = self.profile?.posts.filter({ post in post.id != id }) {
                    self.profile?.posts = posts
                }
                await MainActor.run {
                    defaultsStorage.add(primitiveValue: true, forKey: "needUpdatePostsInNews")
                    self.viewState = .loaded
                }
            } catch {
                await MainActor.run {
                    self.viewState = .alert(title: "Error", subtitle: "Please, try again")
                }
            }
        }
    }
    
    private func getProfile() async {
        do {
            self.profile = try await self.repository.getProfile(id: userId)
            
            await MainActor.run {
                defaultsStorage.removeObject(forKey: "needUpdatePostsInProfile")
                self.viewState = .loaded
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
    
    private func makeScreenError(from appError: AppError) -> ProfileContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: ProfileContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: ProfileContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return ProfileContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
