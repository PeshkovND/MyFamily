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
    
    var profile: Profile? = nil
    private let strings = appDesignSystem.strings
    var audioPlayer: AVQueuePlayer

    init(audioPlayer: AVQueuePlayer) {
        self.audioPlayer = audioPlayer
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
        profile?.posts[index] = postItem
    }
    
    override func onViewEvent(_ event: ProfileViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.profile = self.mockData
                self.viewState = .loaded
            }
            viewState = .initial
        case .pullToRefresh:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.viewState = .loaded
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
    
    private let mockData = Profile(
        id: "0",
        userImageURL: URL(
            string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
        ),
        name: "Иван Иванов",
        status: .online,
        posts: [
            NewsViewPost(
                userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                name: "Иванов Иван",
                contentLabel: "Зацените трэк",
                mediaContent: . Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3")),
                likesCount: 10,
                commentsCount: 10,
                isLiked: false
            ),
            NewsViewPost(
                userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                name: "Иванов Иван",
                contentLabel: nil,
                mediaContent: .Image(url: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg")),
                likesCount: 10,
                commentsCount: 10,
                isLiked: false
            ),
            NewsViewPost(
                userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                name: "Иванов Иван",
                contentLabel: nil,
                // swiftlint:disable line_length
                mediaContent: .Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")),
                likesCount: 10,
                commentsCount: 10,
                isLiked: false
            ),
            NewsViewPost(
                userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                name: "Иванов Иван",
                contentLabel: "Мой топ персонажей дота 2",
                mediaContent: .Image(url: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg")),
                likesCount: 10,
                commentsCount: 0,
                isLiked: true
            ),
        ]
    )
}
