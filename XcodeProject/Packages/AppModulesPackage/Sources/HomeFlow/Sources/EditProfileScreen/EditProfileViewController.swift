import UIKit
import AppEntities
import AppDesignSystem
import AppBaseFlow
import AVKit

final class EditProfileViewController: BaseViewController<EditProfileViewModel,
                                       EditProfileViewEvent,
                                       EditProfileViewState,
                                       EditProfileViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    private var editImageButton: ActionButton { contentView.editImageButton }
    private var nameInputField: UITextField { contentView.nameInputField }
    private var surnameInputField: UITextField { contentView.surnameInputField }
    private var userPhotoView: UIImageView { contentView.userPhotoView }
    private var contentContainer: UIView { contentView.contentContainer }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private let saveButton = UIBarButtonItem(
        barButtonSystemItem: .save,
        target: self,
        action: #selector(saveTapped)
    )
    
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
        
        let menu = UIMenu(options: .displayInline, children: [cameraAction, galleryAction])
        return menu
    }()
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewEvent(.viewDidLoad)
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
        viewModel.onViewEvent(.viewWillDisapear)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        }
    }
    
    @objc func  keyboardWillHide(_ notification: Notification) {
        
    }
    
    override func onViewState(_ viewState: EditProfileViewState) {
        switch viewState {
        case .initial(let firstname, let lastname, let photoURL):
            self.nameInputField.text = firstname
            self.surnameInputField.text = lastname
            self.userPhotoView.setImageUrl(url: photoURL)
        case .imageloading:
            self.saveButton.isEnabled = false
            self.editImageButton.alpha = 0
            self.activityIndicator.startAnimating()
        case .imageLoaded:
            self.saveButton.isEnabled = true
            self.editImageButton.alpha = 1
            self.activityIndicator.stopAnimating()
        case .contentLoadingError:
            break
        }
        
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
        
        editImageButton.menu = addPhotoMenu
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        contentContainer.addGestureRecognizer(gesture)
        
        navigationItem.rightBarButtonItem = saveButton
        
        nameInputField.addTarget(
            self,
            action: #selector(usernameDidChanged),
            for: .editingChanged
        )
        surnameInputField.addTarget(
            self,
            action: #selector(usernameDidChanged),
            for: .editingChanged
        )
    }
    
    @objc func usernameDidChanged() {
        nameInputField.text = nameInputField.text?
            .replacingOccurrences(of: "  ", with: " ")
        surnameInputField.text = surnameInputField.text?
            .replacingOccurrences(of: "  ", with: " ")
        viewModel.onViewEvent(.usernameDidChanged(
            firstname: nameInputField.text ?? "",
            lastName: surnameInputField.text ?? ""
        ))
        
        self.saveButton.isEnabled = viewModel.isSaveButtonActive
    }
    
    @objc
    private func saveTapped() {
        viewModel.onViewEvent(.saveButtonDidTapped)
    }
    
    @objc
    private func closeKeyboard() {
        nameInputField.resignFirstResponder()
        surnameInputField.resignFirstResponder()
    }
    
    private func showContentLoadingError() {
        //        activityIndicator.stopAnimating()
        //        errorImageView.alpha = 1
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            
            if mediaType == UTType.image.identifier { // Проверка на изображение
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
                    viewModel.uploadImage(image: imageData)
                    userPhotoView.image = image
                }
            }
        }
    }
}
