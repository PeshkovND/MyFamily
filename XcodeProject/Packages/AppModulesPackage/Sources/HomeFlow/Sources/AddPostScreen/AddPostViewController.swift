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
        default:
            break
        }
    }
    
    private func open(_ sourceType: UIImagePickerController.SourceType, for mediaType: String) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
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
            if self.textView.textColor != UIColor.lightGray {
                print("send")
            }
        }
    }
    
    @objc
    private func closeKeyboard() {
        textView.resignFirstResponder()
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
            textView.text = appDesignSystem.strings.postScreenCommentPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}
