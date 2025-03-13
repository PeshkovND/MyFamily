//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class AddFamilyViewModel: BaseViewModel<AddFamilyViewEvent,
                                               AddFamilyViewState,
                                               AddFamilyOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private let repository: AddFamilyRepository
    
    init (repository: AddFamilyRepository) {
        self.repository = repository
    }

    override func onViewEvent(_ event: AddFamilyViewEvent) {
        switch event {
        case let .addFamilyTapped(name):
            addFamily(name: name)
        case .viewDidLoad:
            viewState = .initial
        case .backButtonTapped:
            outputEventSubject.send(.back)
        }
    }
    
    func addFamily(name: String) {
        self.viewState = .loading
        Task {
            do {
                try await repository.addFamily(name: name)
                await MainActor.run {
                    self.outputEventSubject.send(.familyCreated)
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
