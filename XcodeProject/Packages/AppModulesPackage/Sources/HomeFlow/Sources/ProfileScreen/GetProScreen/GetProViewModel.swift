import UIKit
import StoreKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class GetProViewModel: BaseViewModel<GetProViewEvent,
                              GetProViewState,
                              GetProOutputEvent> {
    
    private let strings = appDesignSystem.strings
    private let repository: GetProRepository
    private var userInfo: UserInfo?
    private var product: Product?
    
    init(repository: GetProRepository) {
        self.repository = repository
        super.init()
        self.viewState = .loading
    }
    
    override func onViewEvent(_ event: GetProViewEvent) {
        switch event {
        case .buyTapped:
            buy()
        case .viewDidLoad:
            getInfo()
        case.deinit:
            break
        case .closeTapped:
            self.outputEventSubject.send(.finish(isSuccess: false))
        case .restorePurchasesTapped:
            restorePurchases()
        }
    }
    
    private func buy() {
        self.viewState = .purchaseInProgress
        Task {
            guard let product = self.product else { return }
            try await self.repository.purchase(
                product,
                completionHandler: {
                    Task {
                        try await self.repository.setPro()
                        await MainActor.run {
                            self.outputEventSubject.send(.finish(isSuccess: true))
                        }
                    }
                },
                onFailure: { print("failed") },
                onClose: {
                    DispatchQueue.main.async {
                        self.viewState = .loaded(.init(cost: product.displayPrice)) }
                }
            )
        }
    }
    
    private func getInfo() {
        Task {
            self.product = try await self.repository.getProduct()
            await MainActor.run {
                self.viewState = .loaded(.init(cost: product?.displayPrice ?? ""))
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            try await self.repository.restorePurchases {
                try await self.repository.setPro()
                await MainActor.run {
                    self.outputEventSubject.send(.finish(isSuccess: true))
                }
            }
        }
    }
    
    private func makeScreenError(from appError: AppError) -> ProfileContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: ProfileContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: ProfileContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return ProfileContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
