import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class FamilyViewModel: BaseViewModel<FamilyViewEvent,
                                               FamilyViewState,
                                               FamilyOutputEvent> {
    
    private let strings = appDesignSystem.strings
    var persons: [FamilyViewData] = []
    
    override func onViewEvent(_ event: FamilyViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.persons = self.mockData
                self.viewState = .loaded(content: self.persons)
            }
            viewState = .initial
        case .pullToRefresh:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.viewState = .loaded(content: self.persons)
            }
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
                        .first?.message
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
    
    private let mockData: [FamilyViewData] = [
        FamilyViewData(
            id: "0",
            userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Виталий Громяка",
            status: .atHome
        ),
        FamilyViewData(
            id: "1", userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Иванов Иван",
            status: .offline(lastOnline: "11 march, 11:37")
        ),
        FamilyViewData(
            id: "2",
            userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Генадий Генадиев",
            status: .online
        ),
    ]
}
