//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//  Generated using Xcode Screen Template

import UIKit
import Combine
import AppCore
import AppCoreUI

final class ___VARIABLE_productName:identifier___ViewModel: BaseViewModel<___VARIABLE_productName:identifier___Context.ViewEvent,
                                              ___VARIABLE_productName:identifier___Context.ViewState,
                                              ___VARIABLE_productName:identifier___Context.OutputEvent> {
    
    private var strings = AppContainer.provideAppCoreUI().strings

    // TODO: Implement init
    override init() {
        super.init()
    }

    // TODO: Handle view events. Avoid using defaults case
    override func onViewEvent(_ event: ___VARIABLE_productName:identifier___Context.ViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            break
        case .viewDidAppear:
            break
        }
    }
    
    private func makeScreenError(from appError: AppError) -> ___VARIABLE_productName:identifier___Context.ScreenError? {
        nil
    }
    
    // TODO: Implement presentation logic 
    // EXAMPLE
    /*
    private func makeProfileState() -> MyProfileContext.Profile {
        let initials: String = [profile.firstName, profile.lastName]
            .map {
                guard let character = $0.first else { return "" }
                return String(character)
            }
            .joined()
        
        // TODO: Replace with actual level when it's implemented
        let userLevel = "User Level"
        
        return MyProfileContext.Profile(
            username: "\(profile.firstName) \(profile.lastName)",
            avatarLabel: initials,
            level: userLevel,
            levelActionEnabled: false
        )
    }
    */
}
