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
        AVSampleRateKey: 12000,
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
            try recordingSession.setCategory(.playAndRecord, mode: .default)
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
            break
        case .addPostTapped:
            addPost()
        case .recordAudioDidTapped:
            recordTapped()
        case .deleteContentDidTapped:
            self.linkToMediaContent = nil
            self.contentType = nil
            uploadDataTask?.cancel()
        }
    }
    
    func addPost() {
        if linkToMediaContent != nil || postText != nil {
            Task {
                try await self.repository.addPost(
                    text: postText,
                    contentURL: linkToMediaContent,
                    contentType: contentType
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
        linkToMediaContent = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadImage(image: image)
                try Task.checkCancellation()
                self.linkToMediaContent = link
                self.contentType = .image
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    self.linkToMediaContent = nil
                    return
                }
                if error.code == -1009 {
                    self.linkToMediaContent = nil
                    print("error")
                }
            } catch {
                self.linkToMediaContent = nil
            }
        }
    }
    
    func uploadVideo(video: Data) {
        uploadDataTask?.cancel()
        viewState = .contentLoading
        linkToMediaContent = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadVideo(video: video)
                try Task.checkCancellation()
                self.linkToMediaContent = link
                self.contentType = .video
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    self.linkToMediaContent = nil
                    return
                }
                if error.code == -1009 {
                    self.linkToMediaContent = nil
                    print("error")
                }
            } catch {
                self.linkToMediaContent = nil
            }
        }
    }
    
    func uploadAudio(url: URL?) {
        guard let url = url else { return }
        uploadDataTask?.cancel()
        viewState = .contentLoading
        linkToMediaContent = nil
        uploadDataTask = Task.detached {
            do {
                let link = try await self.repository.uploadAudio(url: url)
                try Task.checkCancellation()
                self.linkToMediaContent = link
                self.contentType = .audio
                await MainActor.run {
                    self.viewState = .contentLoaded
                }
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    self.linkToMediaContent = nil
                    return
                }
                if error.code == -1009 {
                    self.linkToMediaContent = nil
                    print("error")
                }
            } catch {
                self.linkToMediaContent = nil
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
    
    func startRecording() {
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            
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
            } else {
                // failed to record!
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        viewState = .audioRecorded
        audioRecorder?.stop()
        self.uploadAudio(url: audioRecorder?.url)
        audioRecorder = nil
    }
    
    private func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
}

extension AddPostViewModel: AVAudioRecorderDelegate {
    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
