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
    var audioPlayer: AVPlayer
    
    init(userId: Int, audioPlayer: AVPlayer, repository: ProfileRepository) {
        self.audioPlayer = audioPlayer
        self.userId = userId
        self.repository = repository
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
    
    override func onViewEvent(_ event: ProfileViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            viewState = .initial
            getProfile()
        case .pullToRefresh:
            getProfile()
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
        }
    }
    
    private func getProfile() {
        Task {
            do {
                self.profile = try await self.repository.getProfile(id: userId)
                
                await MainActor.run {
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
