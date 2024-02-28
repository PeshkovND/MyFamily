//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//  Generated using Xcode Screen Template

import Foundation
import AppCore

struct ___VARIABLE_productName:identifier___Context {
    private init() {}
}

// MARK: - View State

extension ___VARIABLE_productName:identifier___Context {

    enum ViewState: Stubable {

        case initial
        case empty

        // HELP: Add other view states here

        static var stub: ViewState { .empty }
    }
}

// MARK: - Output Event

extension ___VARIABLE_productName:identifier___Context {

    enum OutputEvent {
        case finish
        case back
        
        // HELP: Add other output events here
    }
}

// MARK: - View Event

extension ___VARIABLE_productName:identifier___Context {

    enum ViewEvent {
        case viewDidLoad
        case viewDidAppear
        case `deinit`

        // HELP: Add other view events here
    }
}

extension ___VARIABLE_productName:identifier___Context {

    // TODO: Implement Screen Error
    typealias ScreenError = BaseUIError<Void>
}
