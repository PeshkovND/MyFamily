//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

// MARK: - ViewModel

public protocol ViewModel {

    associatedtype ViewEvent
    associatedtype ViewState

    var viewStatePublisher: Published<ViewState>.Publisher { get }

    func onViewEvent(_ viewEvent: ViewEvent)
}

// MARK: - Stubable

public protocol Stubable {

    static var stub: Self { get }
}

// MARK: - BaseViewModel

open class BaseViewModel<ViewEvent, ViewState: Stubable, OutputEvent>: NSObject, ViewModel {

    // MARK: - View Model Output

    /// Publisher for handling output events (mostly in coordinator)
    public var outputEventPublisher: AnyPublisher<OutputEvent, Never> {
        outputEventSubject.eraseToAnyPublisher()
    }

    /// This subject is used for sending events as output of screen.
    public var outputEventSubject: PassthroughSubject<OutputEvent, Never> = .init()

    /// It encapsulate all data required for filling view. It's similar to `view.render(state:)` approach
    @Published public var viewState: ViewState = .stub

    /// Providing viewState for conforming ViewModel
    public var viewStatePublisher: Published<ViewState>.Publisher { $viewState }

    /// This collection with any cancelable tokens to manage subscription lifecycle
    public var cancelableSet: Set<AnyCancellable> = .init()

    // MARK: - View Model Input

    /// Handling received view events
    /// - Parameter event: Received event
    open func onViewEvent(_ event: ViewEvent) {}

    public override init() {}
}
