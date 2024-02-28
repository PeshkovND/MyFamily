//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import Utilities

open class BaseViewController<
    SpecificViewModel: ViewModel,
    ViewEvent,
    ViewState,
    View: BaseView
>: UIViewController where
    ViewEvent == SpecificViewModel.ViewEvent,
    ViewState == SpecificViewModel.ViewState {

    public var contentView: View {
        guard let contentView = view as? View else {
            assertionFailure("Current view must be \(View.self)")
            return View()
        }
        return contentView
    }

    public let viewModel: SpecificViewModel

    public var cancelableSet = Set<AnyCancellable>()

    public var disableKeyboardAutoManaging = true

    /// It's used to enable Navigation bar on
    /// It should be used only for the first view controller in flow with navigation bar
    ///
    /// Default value: false
    public var shouldManageShowingNavigationBar = false

    public init(viewModel: SpecificViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = View()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        bindView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldManageShowingNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         Info: It's necessary for the following functionality to work correctly:
         User makes a swipe from left corner to center for return to previous screen, but cancels action.
         */
        if disableKeyboardAutoManaging {
            disableKeyboardHander()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         Info: It's necessary for the following functionality to work correctly:
         User makes a swipe from left corner to center for return to previous screen, but cancels action.
         */
        if disableKeyboardAutoManaging {
            enableKeyboardHander()
        }

        // Workaround to detect push method and avoid pop.
        var hasAddedToHierarchy: Bool {
            guard let navigationController = navigationController else { return false }
            return navigationController.viewControllers.contains(self)
        }

        if shouldManageShowingNavigationBar && !hasAddedToHierarchy {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    private func bindView() {
        viewModel.viewStatePublisher
            .sink { [weak self] (viewState: SpecificViewModel.ViewState) in
                guard let self = self else { return }
                self.onViewState(viewState)
            }
            .store(in: &cancelableSet)
    }

    open func onViewState(_ viewState: ViewState) {}
}

// MARK: - KeyboardAutoManaging

extension BaseViewController: KeyboardAutoManaging {}
