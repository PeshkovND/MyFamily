import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class AddPostViewModel: BaseViewModel<AddPostViewEvent,
                              AddPostViewState,
                              AddPostOutputEvent> {
    
    private var uploadDataTask: Task<Void, Never>?
    private let repository: AddPostRepository
    private let strings = appDesignSystem.strings
    private let recorderSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12_000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    private var linkToMediaContent: URL?
    private var recordingSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    
    var contentType: ContentType?
    var postText: String?
    
    init(repository: AddPostRepository) {
        self.repository = repository
        super.init()
        
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("error on creating record session")
        }
    }
    
    override func onViewEvent(_ event: AddPostViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            viewState = .initial
        case .addPostTapped:
            addPost()
        case .recordAudioDidTapped:
            recordTapped()
        case .deleteContentDidTapped:
            self.linkToMediaContent = nil
            self.contentType = nil
            uploadDataTask?.cancel()
        case .backTapped:
            outputEventSubject.send(.finish(isPostAdded: false))
        case .mediaChoosed(data: let data, contentType: let contentType):
            switch contentType {
            case .image:
                self.uploadMedia(data: data, contentType: .image)
            case .video:
                self.uploadMedia(data: data, contentType: .video)
            case .audio:
                break
            }
        }
    }
    
    private func addPost() {
        guard linkToMediaContent != nil || postText != nil else { return }
        self.viewState = .loading
        Task {
            do {
                try await self.repository.addPost(
                    text: postText,
                    contentURL: linkToMediaContent,
                    contentType: contentType
                )
                
                await MainActor.run {
                    outputEventSubject.send(.finish(isPostAdded: true))
                }
            } catch {
                await MainActor.run {
                    self.viewState = .error
                }
            }
        }
    }
    
    func uploadMedia(data: Data, contentType: ContentType) {
        uploadDataTask?.cancel()
        viewState = .contentLoading
        linkToMediaContent = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadMedia(data: data, contentType: contentType)
                try Task.checkCancellation()
                self.linkToMediaContent = link
                self.contentType = .image
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 { // Проверяем закрытие таски
                    self.linkToMediaContent = nil
                    return
                }
                await MainActor.run { self.showContentError() }
            } catch {
                await MainActor.run { self.showContentError() }
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
    
    private func startRecording() {
        recordingSession.requestRecordPermission { [unowned self] allowed in
            if allowed {
                DispatchQueue.main.async {
                    let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
                    
                    do {
                        self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: self.recorderSettings)
                        guard let audioRecorder = self.audioRecorder else { return }
                        audioRecorder.delegate = self
                        audioRecorder.record()
                        self.viewState = .audioRecording
                    } catch {
                        self.finishRecording(success: false)
                    }
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func finishRecording(success: Bool) {
        viewState = .audioRecorded
        audioRecorder?.stop()
        guard let url = audioRecorder?.url else { return }
        do {
            let data = try Data(contentsOf: url)
            self.uploadMedia(data: data, contentType: .audio)
            audioRecorder = nil
        } catch {
            return
        }
    }
    
    private func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    private func showContentError() {
        self.viewState = .contentLoadingError
        self.linkToMediaContent = nil
    }
}

extension AddPostViewModel: AVAudioRecorderDelegate {
    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
