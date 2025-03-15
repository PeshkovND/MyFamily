//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class FamilyCheckingViewModel: BaseViewModel<FamilyCheckingViewEvent,
                                               FamilyCheckingViewState,
                                FamilyCheckingOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private let repository: FamilyCheckingRepository
    
    init (repository: FamilyCheckingRepository) {
        self.repository = repository
    }
    
    override func onViewEvent(_ event: FamilyCheckingViewEvent) {
        switch event {
        case .viewDidAppear:
            familyChecking()
        case .retryButtonTapped:
            familyChecking()
        }
    }
    
    func familyChecking() {
        self.viewState = .loading
        Task {
            do {
                if try await repository.userHasFamily() {
                    await MainActor.run {
                        self.outputEventSubject.send(.familyFound)
                    }
                } else {
                    await MainActor.run {
                        self.outputEventSubject.send(.familyNotFound)
                    }
                }
            } catch {
                await MainActor.run {
                    self.viewState = .error(
                        title: "Ошибка синхронизации данных",
                        subtitle: "Попробуйте еще раз"
                    )
                }
            }
        }
    }
}
