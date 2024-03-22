import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

struct DataToLoad {
    let data: Data
    let contentType: ContentType
}

final class AddPostViewModel: BaseViewModel<AddPostViewEvent,
                                               AddPostViewState,
                                               AddPostOutputEvent> {
    
    private let repository: AddPostRepository
    private let strings = appDesignSystem.strings
    
    var dataToLoad: DataToLoad?
    
    init(repository: AddPostRepository) {
        self.repository = repository
        super.init()
    }
    
    override func onViewEvent(_ event: AddPostViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            break
        case .addPostTapped:
            break
        }
    }
    
    func uploadImage(image: Data) {
        Task {
            try await self.repository.uploadImage(image: image)
        }
    }
    
    func uploadVideo(video: Data) {
        Task {
            try await self.repository.uploadVideo(video: video)
        }
    }
    
    private func makeScreenError(from appError: AppError) -> AddPostContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: AddPostContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: AddPostContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return AddPostContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
