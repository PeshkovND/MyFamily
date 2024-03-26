import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

final class AddPostViewController: BaseViewController<AddPostViewModel,
                                AddPostViewEvent,
                                AddPostViewState,
                                AddPostViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var textView: UITextView { contentView.textView }
    private var sendButton: ActionButton { contentView.sendButton }
    private var addMediaContainer: UIView { contentView.addMediaContainer }
    private var addAudioButton: ActionButton { contentView.addAudioButton }
    private var addVideoButton: ActionButton { contentView.addVideoButton }
    private var addPhotoButton: ActionButton { contentView.addPhotoButton }
    private var mediaContentContainer: UIView { contentView.mediaContentContainer }
    private var contentImageView: UIImageView { contentView.contentImageView }
    private var contentVideoView: VideoPlayerView { contentView.contentVideoView }
    private var contentAudioView: UIImageView { contentView.contentAudioView }
    private var deleteContentButton: ActionButton { contentView.deleteContentButton }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var errorImageView: UIImageView { contentView.errorImageView }
    
    private(set) lazy var addPhotoMenu: UIMenu = {
        let cameraAction = UIAction(
            title: appDesignSystem.strings.addPostCamera,
            image: UIImage(systemName: "camera")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            )) { _ in self.open(.camera, for: UTType.image.identifier) }
        
        let galleryAction = UIAction(
            title: appDesignSystem.strings.addPostGallery,
            image: UIImage(systemName: "photo.on.rectangle")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            )) { _ in self.open(.photoLibrary, for: UTType.image.identifier) }
        
        let menu = UIMenu(options: .displayInline, children: [galleryAction, cameraAction])
        return menu
    }()
    
    private(set) lazy var addVideoMenu: UIMenu = {
        let cameraAction = UIAction(
            title: appDesignSystem.strings.addPostCamera,
            image: UIImage(systemName: "camera")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            )) { _ in self.open(.camera, for: UTType.movie.identifier) }
        
        let galleryAction = UIAction(
            title: appDesignSystem.strings.addPostGallery,
            image: UIImage(systemName: "arrow.up.right.video")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            )) { _ in self.open(.photoLibrary, for: UTType.movie.identifier) }
        
        let menu = UIMenu(options: .displayInline, children: [galleryAction, cameraAction])
        return menu
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeKeyboard()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addMediaContainer.snp.removeConstraints()
            addMediaContainer.snp.updateConstraints {
                $0.bottom.equalTo(view.snp.bottom).inset(keyboardSize.height - 1)
                $0.leading.equalToSuperview().inset(-1)
                $0.trailing.equalToSuperview().inset(-1)
                $0.height.equalTo(64)
            }
        }
    }
    
    @objc func  keyboardWillHide(_ notification: Notification) {
        addMediaContainer.snp.removeConstraints()
        addMediaContainer.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(-1)
            $0.leading.equalToSuperview().inset(-1)
            $0.trailing.equalToSuperview().inset(-1)
            $0.height.equalTo(64)
        }
    }
    
    override func onViewState(_ viewState: AddPostViewState) {
        switch viewState {
        case .contentLoaded:
            activityIndicator.stopAnimating()
            sendButton.isEnabled = true
        case .initial:
            break
        case .contentLoading:
            sendButton.isEnabled = false
            activityIndicator.startAnimating()
        case .audioRecording:
            recordingDidBegin()
        case .audioRecorded:
            recordingDidEnd()
            addAudio()
        case .contentLoadingError:
            showContentLoadingError()
        }
        
    }
    
    private func recordingDidBegin() {
        let image = UIImage(systemName: "stop.circle")?
            .withTintColor(colors.backgroundSecondaryVariant, renderingMode: .alwaysOriginal)
            .scaleImageToFitSize(size: .init(width: 30, height: 30))
        self.addAudioButton.setImage(image, for: .normal)
    }
    
    private func recordingDidEnd() {
        let image = UIImage(systemName: "mic")?
            .withTintColor(colors.backgroundSecondaryVariant, renderingMode: .alwaysOriginal)
            .scaleImageToFitSize(size: .init(width: 30, height: 30))
        self.addAudioButton.setImage(image, for: .normal)
    }
    
    private func open(_ sourceType: UIImagePickerController.SourceType, for mediaType: String) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.mediaTypes = [mediaType]
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
    
    private func configureView() {
        self.contentView.backgroundColor = colors.backgroundPrimary
        viewModel.onViewEvent(.viewDidLoad)
        textView.delegate = self
        
        addPhotoButton.menu = addPhotoMenu
        addVideoButton.menu = addVideoMenu
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addMediaContainer.addGestureRecognizer(gesture)
        
        sendButton.onTap = {
            self.viewModel.addPost()
        }
        
        deleteContentButton.onTap = {
            self.viewModel.onViewEvent(.deleteContentDidTapped)
            self.sendButton.isEnabled = true
            self.deleteContent()
        }
        
        addAudioButton.onTap = { self.viewModel.onViewEvent(.recordAudioDidTapped) }
    }
    
    @objc
    private func closeKeyboard() {
        textView.resignFirstResponder()
    }
    
    private func deleteContent() {
        contentImageView.snp.removeConstraints()
        contentImageView.removeFromSuperview()
        contentVideoView.snp.removeConstraints()
        contentVideoView.removeFromSuperview()
        contentAudioView.snp.removeConstraints()
        contentAudioView.removeFromSuperview()
        deleteContentButton.snp.removeConstraints()
        deleteContentButton.removeFromSuperview()
        
        self.mediaContentContainer.snp.remakeConstraints {
            $0.height.equalTo(0)
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(80)
            $0.bottom.equalTo(self.addMediaContainer.snp.top)
        }
    }
    
    private func setupContentContainer() {
        mediaContentContainer.snp.remakeConstraints {
            $0.height.equalTo(80)
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(80)
            $0.bottom.equalTo(addMediaContainer.snp.top)
        }
        errorImageView.alpha = 0
        mediaContentContainer.addSubview(activityIndicator)
        mediaContentContainer.addSubview(errorImageView)
        activityIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        errorImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        activityIndicator.startAnimating()
        
        mediaContentContainer.addSubview(deleteContentButton)
        
        deleteContentButton.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(32)
            $0.top.equalToSuperview().inset(-10)
            $0.trailing.equalToSuperview().inset(-10)
        }
    }
    
    private func showContentLoadingError() {
        activityIndicator.stopAnimating()
        errorImageView.alpha = 1
    }
    
    private func addImage(_ image: UIImage) {
        deleteContent()
        
        contentImageView.image = image
        mediaContentContainer.addSubview(contentImageView)
        contentImageView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalTo(80)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        setupContentContainer()
    }
    
    private func addAudio() {
        deleteContent()
        
        mediaContentContainer.addSubview(contentAudioView)
        contentAudioView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalTo(80)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        setupContentContainer()
    }
    
    private func addVideo(_ url: URL) {
        deleteContent()
        
        contentVideoView.addVideoToPlayer(videoUrl: url)
        contentVideoView.play()
        mediaContentContainer.addSubview(contentVideoView)
        contentVideoView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.width.equalTo(80)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        setupContentContainer()
    }
}

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = appDesignSystem.strings.addPostScreenPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.textView.textColor == UIColor.lightGray ||
            self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.viewModel.postText = nil
        } else {
            self.viewModel.postText = textView.text
        }
    }
}

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == UTType.movie.identifier { // Проверка на видео
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    do {
                        let videoData = try Data(contentsOf: videoURL)
                        addVideo(videoURL)
                        viewModel.uploadVideo(video: videoData)
                    } catch {
                        print("Error converting video to Data: \(error)")
                    }
                }
            } else if mediaType == UTType.image.identifier { // Проверка на изображение
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
                    addImage(image)
                    viewModel.uploadImage(image: imageData)
                }
            }
        }
    }
}
