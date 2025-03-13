//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class AddFamilyForkViewModel: BaseViewModel<AddFamilyForkViewEvent,
                                    AddFamilyForkViewState,
                                    AddFamilyForkOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private var validField: String { "number" }
    fileprivate let authService: AuthService
    var username: String { authService.account?.firstName ?? "friend" }
    
    init (authService: AuthService) {
        self.authService = authService
    }

    override func onViewEvent(_ event: AddFamilyForkViewEvent) {
        switch event {
        case .addNewFamilyTapped:
            self.outputEventSubject.send(.openAddNewFamilyScreen)
        case .enterExistingFamilyTapped:
            self.outputEventSubject.send(.openEnterExistingFamilyScreen)
        case .logOutTapped:
            self.outputEventSubject.send(.logOut)
        }
    }
}
