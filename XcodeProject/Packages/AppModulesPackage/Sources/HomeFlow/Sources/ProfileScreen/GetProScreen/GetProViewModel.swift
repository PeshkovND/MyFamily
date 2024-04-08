import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class GetProViewModel: BaseViewModel<GetProViewEvent,
                              GetProViewState,
                              GetProOutputEvent> {
    
    private let strings = appDesignSystem.strings
    private let repository: GetProRepository
    private var userInfo: UserInfo?
    
    init(repository: GetProRepository) {
        self.repository = repository
        super.init()
    }
    
    override func onViewEvent(_ event: GetProViewEvent) {
        switch event {
        case .buyTapped:
            break
        case .viewDidLoad:
            getProfile()
        case.deinit:
            break
        }
    }
    
    
    private func getProfile() {
        self.userInfo = self.repository.getCurrentUserInfo()
        guard let userInfo = self.userInfo else { return }
        self.viewState = .loaded(userInfo)
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
