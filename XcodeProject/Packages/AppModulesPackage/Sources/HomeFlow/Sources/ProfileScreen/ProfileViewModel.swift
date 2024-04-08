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
            self.profile = try await self.repository.getProfile(id: userId)
            
            await MainActor.run {
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
    
    private let mockData = [
        Profile(
            id: 1,
            userImageURL: URL(
                string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"
            ),
            name: "Иван Иванов",
            status: .online,
            posts: [
                NewsViewPost(
                    id: "0",
                    userId: 1,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: "Зацените трэк",
                    mediaContent: . Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "1",
                    userId: 1,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "1",
                    userId: 1,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    // swiftlint:disable line_length
                    mediaContent: .Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "2",
                    userId: 1,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: "Какой я здесь красивый",
                    mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
                    likesCount: 10,
                    commentsCount: 0,
                    isLiked: true
                )
            ]
        ),
        Profile(
            id: 0,
            userImageURL: URL(
                string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"
            ),
            name: "Виталий Виталиев",
            status: .online,
            posts: [
                NewsViewPost(
                    id: "0",
                    userId: 0,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: "Зацените трэк",
                    mediaContent: . Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "1",
                    userId: 0,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "2",
                    userId: 0,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    // swiftlint:disable line_length
                    mediaContent: .Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
            ]
        ),
        Profile(
            id: 2,
            userImageURL: URL(
                string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"
            ),
            name: "Генадий Генадиев",
            status: .online,
            posts: [
                NewsViewPost(
                    id: "0",
                    userId: 2,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: "Зацените трэк",
                    mediaContent: . Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "1",
                    userId: 2,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "2",
                    userId: 2,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: nil,
                    // swiftlint:disable line_length
                    mediaContent: .Audio(url: URL(string: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3")),
                    likesCount: 10,
                    commentsCount: 10,
                    isLiked: false
                ),
                NewsViewPost(
                    id: "3",
                    userId: 2,
                    userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
                    name: "Иванов Иван",
                    contentLabel: "Какой я здесь красивый",
                    mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
                    likesCount: 10,
                    commentsCount: 0,
                    isLiked: true
                )
            ]
        ),
    ]
}
