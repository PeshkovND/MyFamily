//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine

public protocol Eventable {

    associatedtype Event

    var events: AnyPublisher<Event, Never> { get }

    var eventsCancelableToken: AnyCancellable? { get set }
}

public protocol Coordinator: AnyObject {
    func start()
}

public protocol EventCoordinator: Coordinator, Eventable {}

open class BaseCoordinator {

    private(set) var childCoordinators: [Coordinator] = []

    public init() {}

    public func addDependency(_ coordinator: Coordinator) {
        for element in childCoordinators {
            if element === coordinator { return } // swiftlint:disable:this for_where
        }
        childCoordinators.append(coordinator)
    }

    public func removeDependency(_ coordinator: Coordinator?) {
        guard
            childCoordinators.isEmpty == false,
            let coordinator = coordinator
            else { return }

        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator { // swiftlint:disable:this for_where
                childCoordinators.remove(at: index)
                break
            }
        }
    }

    public func removeAll() {
        childCoordinators.removeAll()
    }
}

// MARK: - BaseCoordinator Helpers

extension BaseCoordinator {

    public func addDependency<T: EventCoordinator>(
        _ coordinator: T,
        token: AnyCancellable
    ) {
        for element in childCoordinators {
            if element === coordinator { return } // swiftlint:disable:this for_where
        }
        var eventCoordinator = coordinator
        eventCoordinator.eventsCancelableToken = token
        childCoordinators.append(eventCoordinator)
    }
}
