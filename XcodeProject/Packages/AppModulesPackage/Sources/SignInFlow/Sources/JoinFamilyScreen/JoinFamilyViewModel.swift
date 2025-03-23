//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class JoinFamilyViewModel: BaseViewModel<JoinFamilyViewEvent,
                                               JoinFamilyViewState,
                                JoinFamilyOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private let repository: JoinFamilyRepository
    
    init (repository: JoinFamilyRepository) {
        self.repository = repository
    }
    
    override func onViewEvent(_ event: JoinFamilyViewEvent) {
        switch event {
        case .joinFamilyTapped(let code):
            self.viewState = .loading
            joinFamily(code: code)
        case .backButtonTapped:
            outputEventSubject.send(.back)
        }
    }
    
    func joinFamily(code: String) {
        Task {
            do {
                try await repository.joinFamily(code: code)
                await MainActor.run {
                    self.outputEventSubject.send(.familyJoined)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .error(
                        title: "Ошибка добавления семьи",
                        subtitle: "Попробуйте еще раз"
                    )
                }
            }
        }
    }
}
