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
    var linkToMediaContent: URL?
    private var userName = ""
    private var userSurname = ""
    private var userPhotoUrl: URL?
    var isSaveButtonActive: Bool {
        !(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          || userSurname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    init(repository: EditProfileRepository) {
        self.repository = repository
        super.init()
    }
    
    override func onViewEvent(_ event: EditProfileViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            guard let userInfo = self.repository.getUserInfo() else { return }
            self.userName = userInfo.firstName
            self.userSurname = userInfo.lastName
            self.userPhotoUrl = userInfo.photoURL
            self.linkToMediaContent = userPhotoUrl
            viewState = .initial(
                firstname: self.userName,
                lastname: userSurname,
                photoUrl: userPhotoUrl
            )
        case .saveButtonDidTapped:
            self.viewState = .loading
            editUser()
        case .usernameDidChanged(let firstName, let lastName):
            self.userName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            self.userSurname = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        case .onBack:
            outputEventSubject.send(.onBack)
        }
    }
    
    private func editUser() {
        Task {
            do {
                guard let url = self.linkToMediaContent else { return }
                try await self.repository.editUser(
                    name: self.userName,
                    surname: self.userSurname,
                    imageURL: url
                )
                await MainActor.run {
                    outputEventSubject.send(.saveTapped)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .failure
                }
            }
        }
    }
    
    func uploadImage(image: Data) {
        uploadDataTask?.cancel()
        viewState = .imageloading
        linkToMediaContent = userPhotoUrl
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
            self.linkToMediaContent = userPhotoUrl
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
        self.linkToMediaContent = userPhotoUrl
    }
}
