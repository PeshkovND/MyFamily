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
    
    init(postId: String, audioPlayer: AVQueuePlayer) {
        self.audioPlayer = audioPlayer
        self.postId = postId
        super.init()
    }
    
    override func onViewEvent(_ event: PostViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.post = self.mockData.first { elem in
                    elem.id == self.postId
                }
                self.comments = self.mockComments
                self.viewState = .loaded
            }
            viewState = .initial
        case .pullToRefresh:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.viewState = .loaded
            }
        case .profileTapped(id: let id):
            outputEventSubject.send(.personCardTapped(id: id))
        case .shareTapped(id: let id):
            outputEventSubject.send(.shareTapped(id: id))
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
    
    private let mockData: [NewsViewPost] = [
        NewsViewPost(
            id: "0",
            userId: "1",
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
            userId: "1",
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
            userId: "1",
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
            userId: "1",
            userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            name: "Иванов Иван",
            contentLabel: "Какой я здесь красивый",
            mediaContent: .Image(url: URL(string: "https://directorsnotes.com/wp-content/uploads/2011/12/drive_02-1440x500-1.jpg")),
            likesCount: 10,
            commentsCount: 0,
            isLiked: true
        ),
        NewsViewPost(
            id: "4",
            userId: "1",
            userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            name: "Иванов Иван",
            // swiftlint:disable line_length
            contentLabel: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            mediaContent: nil,
            likesCount: 10,
            commentsCount: 0,
            isLiked: true
        ),
        NewsViewPost(
            id: "5",
            userId: "1",
            userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            name: "Иванов Иван",
            // swiftlint:disable line_length
            contentLabel: nil,
            mediaContent: .Video(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4")),
            likesCount: 10,
            commentsCount: 0,
            isLiked: true
        ),
        NewsViewPost(
            id: "6",
            userId: "1",
            userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            name: "Иванов Иван",
            // swiftlint:disable line_length
            contentLabel: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            mediaContent: .Image(url: URL(
                // swiftlint:disable:next line_length
                string: "https://resizer.mail.ru/p/58249a62-2772-5b1c-bcd6-53a94c958a3f/AQAGCLbbuD6T0SQcOPhfslEEWx5BmkmWL91f2gZ1q4lVGYlFhMYC67aa5f8foMI_Sae2HL4lWf6EX809-rZ-Yg5zb28.jpg"
            )),
            likesCount: 10,
            commentsCount: 0,
            isLiked: true
        ),
        NewsViewPost(
            id: "7",
            userId: "1",
            userImageURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            name: "Иванов Иван",
            // swiftlint:disable line_length
            contentLabel: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            mediaContent: .Video(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")),
            likesCount: 10,
            commentsCount: 0,
            isLiked: true
        )
    ]
    
    private let mockComments: [Comment] = [
        Comment(
            userId: "0",
            username: "Виталий Виталиев",
            imageUrl:  URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            text: "Очень круто"
        ),
        Comment(
            userId: "0",
            username: "Виталий Виталиев",
            imageUrl:  URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        ),
        Comment(
            userId: "0",
            username: "Виталий Виталиев",
            imageUrl:  URL(string: "https://m.media-amazon.com/images/M/MV5BMTQzMjkwNTQ2OF5BMl5BanBnXkFtZTgwNTQ4MTQ4MTE@._V1_.jpg"),
            text: "Очень круто"
        ),
    ]
}
