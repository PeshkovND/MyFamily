import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow

final class GetProViewController: BaseViewController<GetProViewModel,
                                GetProViewEvent,
                                GetProViewState,
                                GetProViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: GetProViewState) {
        switch viewState {
        case .loaded:
            break
        default:
            break
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
    }
}
