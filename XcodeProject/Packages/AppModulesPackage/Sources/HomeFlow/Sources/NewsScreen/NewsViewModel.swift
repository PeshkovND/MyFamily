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

    override func onViewEvent(_ event: NewsViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.posts = [
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        contentImageURL: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg"),
                        contentVideoURL: nil,
                        contentAudioURL: nil
                    ),
                    NewsViewPost(
                        userImageURL: URL(string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"),
                        name: "Виталий Цаль",
                        contentImageURL: URL(string: "https://hawk.live/storage/post-images/petushara-dota-2-best-heroes-3570.jpg"),
                        contentVideoURL: nil,
                        contentAudioURL: nil
                    )
                ]
                self.viewState = .loaded(content: self.posts)
            }
            viewState = .initial
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
