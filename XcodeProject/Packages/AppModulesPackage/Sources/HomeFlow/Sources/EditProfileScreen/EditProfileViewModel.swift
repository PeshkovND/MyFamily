import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class EditProfileViewModel: BaseViewModel<EditProfileViewEvent,
                                  EditProfileViewState,
                                  EditProfileOutputEvent> {
    
    private var uploadDataTask: Task<Void, Never>?
    private let repository: EditProfileRepository
    private let strings = appDesignSystem.strings
    var postText: String?
    var linkToMediaContent: URL?
    
    init(repository: EditProfileRepository) {
        self.repository = repository
        super.init()
    }
    
    override func onViewEvent(_ event: EditProfileViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            break
        }
    }
    
    func uploadImage(image: Data) {
        uploadDataTask?.cancel()
        viewState = .imageloading
        linkToMediaContent = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadImage(image: image)
                try Task.checkCancellation()
                self.linkToMediaContent = link
                await MainActor.run {
                    self.viewState = .imageLoaded
                }
            } catch let error as NSError {
                await self.catchNSError(error: error)
            } catch {
                await MainActor.run { self.showContentError() }
            }
        }
    }
    
    private func catchNSError(error: NSError) async {
        if error.domain == NSURLErrorDomain && error.code == -999 {
            self.linkToMediaContent = nil
            return
        }
        await MainActor.run { self.showContentError() }
    }
    
    private func makeScreenError(from appError: AppError) -> EditProfileContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: EditProfileContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: EditProfileContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return AddPostContext.ScreenError.defaultUIError(from: appError)
        }
    }

    private func showContentError() {
        self.viewState = .contentLoadingError
        self.linkToMediaContent = nil
    }
}
