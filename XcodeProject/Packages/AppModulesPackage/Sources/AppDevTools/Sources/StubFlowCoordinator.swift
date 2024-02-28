//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

import Utilities
import AppDesignSystem
import AppBaseFlow

// MARK: Stub Flow

public final class StubFlowCoordinator: EventCoordinator {

    public enum Event {
        case finish
    }

    public var events: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var eventsCancelableToken: AnyCancellable?

    private var setCancelable = Set<AnyCancellable>()
    private var eventSubject: PassthroughSubject<Event, Never> = .init()

    private weak var navigationController: UINavigationController?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "Stub flow"
        navigationController?.setViewControllers([viewController], animated: false)
    }
}

// MARK: Title Stub View Controller

public final class TitleStubViewController: UIViewController {
    
    private var designSystem = appDesignSystem

    public var stubTitle: String = "" {
        didSet {
            label.text = stubTitle
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = appDesignSystem.colors.labelPrimary
        label.font = label.font.withSize(24)
        return label
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = appDesignSystem.colors.backgroundPrimary

        view.addSubview(label)

        label.snp.makeConstraints {
            $0.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}
