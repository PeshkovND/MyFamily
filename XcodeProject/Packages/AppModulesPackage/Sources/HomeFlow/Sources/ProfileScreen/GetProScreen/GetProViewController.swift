import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow

struct GetProModel {
    let cost: String
}

final class GetProViewController: BaseViewController<GetProViewModel,
                                GetProViewEvent,
                                GetProViewState,
                                GetProViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    private var stackView: UIStackView { contentView.stackView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var purchaseProgressActivityIndicator: UIActivityIndicatorView { contentView.purchaseProgressActivityIndicator }
    private var closeButton: ActionButton { contentView.closeButton }
    private var buyButton: ActionButton { contentView.buyButton }
    private var restorePurchaseButton: ActionButton { contentView.restorePurchaseButton }
    private var failedStackView: UIStackView { contentView.failedStackView }
    private var retryButton: ActionButton { contentView.retryButton }
    
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
        case .loaded(let model):
            buyButton.setTitle(appDesignSystem.strings.getProBuy + " " + model.cost, for: .normal)
            self.stackView.alpha = 1
            self.activityIndicator.stopAnimating()
            isModalInPresentation = false
            purchaseProgressActivityIndicator.stopAnimating()
            closeButton.isEnabled = true
        case .loading:
            failedStackView.alpha = 0
            self.activityIndicator.startAnimating()
            stackView.alpha = 0
        case .initial:
            break
        case .failed:
            failedStackView.alpha = 1
            self.activityIndicator.stopAnimating()
        case .purchaseInProgress:
            buyButton.setTitle("", for: .normal)
            purchaseProgressActivityIndicator.startAnimating()
            isModalInPresentation = true
            closeButton.isEnabled = false
        case .purchaseFailed:
            let alert = UIAlertController(
                title: appDesignSystem.strings.getProPurchaseFailedTitle,
                message: appDesignSystem.strings.getProPurchaseFailedDescription,
                preferredStyle: .alert
            )
            alert.addAction(.okAction())
            self.present(alert, animated: true)
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        
        closeButton.onTap = {
            self.viewModel.onViewEvent(.closeTapped)
        }
        
        buyButton.onTap = {
            self.viewModel.onViewEvent(.buyTapped)
        }
        
        restorePurchaseButton.onTap = {
            self.viewModel.onViewEvent(.restorePurchasesTapped)
        }
        
        retryButton.onTap = {
            self.viewModel.onViewEvent(.retryTapped)
        }
    }
}
