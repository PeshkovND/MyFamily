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
    
    private var uploadDataTask: Task<Void, Never>?
    private let repository: AddPostRepository
    private let strings = appDesignSystem.strings
    var postText: String?
    var linkToPost: URL?
    
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
            addPost()
        }
    }
    
    func addPost() {
        if linkToPost != nil || postText != nil {
            Task {
                try await self.repository.addPost(
                    text: postText,
                    contentURL: linkToPost,
                    contentType: dataToLoad?.contentType
                )
                
                await MainActor.run {
                    outputEventSubject.send(.addedPost)
                }
            }
        } else {
            print("nope")
        }
    }
    
    func uploadImage(image: Data) {
        uploadDataTask?.cancel()
        viewState = .contentLoading
        linkToPost = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadImage(image: image)
                try Task.checkCancellation()
                self.linkToPost = link
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    self.linkToPost = nil
                    return
                }
                if error.code == -1009 {
                    self.linkToPost = nil
                    print("error")
                }
            } catch {
                self.linkToPost = nil
            }
        }
    }
    
    func uploadVideo(video: Data) {
        uploadDataTask?.cancel()
        viewState = .contentLoading
        linkToPost = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadVideo(video: video)
                try Task.checkCancellation()
                self.linkToPost = link
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    self.linkToPost = nil
                    return
                }
                if error.code == -1009 {
                    self.linkToPost = nil
                    print("error")
                }
            } catch {
                self.linkToPost = nil
            }
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
