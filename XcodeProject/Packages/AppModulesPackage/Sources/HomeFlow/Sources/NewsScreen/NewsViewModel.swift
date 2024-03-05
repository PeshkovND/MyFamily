import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class NewsViewModel: BaseViewModel<NewsViewEvent,
                                               NewsViewState,
                                               NewsOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private var validField: String { "number" }
    var posts: [NewsViewPost] = []
    
    func likeButtonDidTappedOn(post: NewsViewPost, at index: Int) {
        var postItem = post
        if postItem.isLiked {
            postItem.likesCount -= 1
        } else {
            postItem.likesCount += 1
        }
        postItem.isLiked.toggle()
        posts[index] = postItem
    }

    // swiftlint:disable function_body_length
    override func onViewEvent(_ event: NewsViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            // swiftlint:disable closure_body_length
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.posts = [
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        contentLabel: nil,
                        contentImageURL: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg"),
                        contentVideoURL: nil,
                        contentAudioURL: nil,
                        likesCount: 10,
                        commentsCount: 10,
                        isLiked: false
                    ),
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        contentLabel: "Мой топ персонажей дота 2",
                        contentImageURL: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg"),
                        contentVideoURL: nil,
                        contentAudioURL: nil,
                        likesCount: 10,
                        commentsCount: 0,
                        isLiked: true
                    ),
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        // swiftlint:disable line_length
                        contentLabel: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                        contentImageURL: nil,
                        contentVideoURL: nil,
                        contentAudioURL: nil,
                        likesCount: 10,
                        commentsCount: 0,
                        isLiked: true
                    ),
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        // swiftlint:disable line_length
                        contentLabel: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                        contentImageURL: URL(
                            // swiftlint:disable:next line_length
                            string: "https://resizer.mail.ru/p/58249a62-2772-5b1c-bcd6-53a94c958a3f/AQAGCLbbuD6T0SQcOPhfslEEWx5BmkmWL91f2gZ1q4lVGYlFhMYC67aa5f8foMI_Sae2HL4lWf6EX809-rZ-Yg5zb28.jpg"
                        ),
                        contentVideoURL: nil,
                        contentAudioURL: nil,
                        likesCount: 10,
                        commentsCount: 0,
                        isLiked: true
                    )
                ]
                self.viewState = .loaded(content: self.posts)
            }
            viewState = .initial
        case .addPostTapped:
            outputEventSubject.send(.addPost)
        }
    }

    private func makeScreenError(from appError: AppError) -> NewsContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: NewsContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first( where: { $0.field == validField })?.message
                )
                return screenError
            }
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
