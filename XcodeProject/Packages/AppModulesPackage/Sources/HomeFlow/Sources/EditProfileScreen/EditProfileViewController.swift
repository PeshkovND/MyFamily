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
    private var loadingView: UIView { contentView.loadingView }
    private lazy var saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    private lazy var backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(backTapped))
    
    private var isLoadingShowing = false {
        willSet {
            UIView.animate {
                loadingView.alpha = newValue ? 1 : 0
            }
            self.saveButton.isEnabled = !newValue
            self.backButton.isEnabled = !newValue
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !newValue
        }
    }
    
    private let errorImage = UIImage(systemName: "exclamationmark.triangle.fill")?
        .withTintColor(appDesignSystem.colors.backgroundPrimary,
                       renderingMode: .alwaysOriginal)
        .scaleImageToFitSize(size: .init(width: 32, height: 32))
    
    private let editImage = UIImage(systemName: "photo.badge.plus")?
        .withTintColor(.white, renderingMode: .alwaysOriginal)
        .scaleImageToFitSize(size: .init(width: 32, height: 32))
    
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
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeKeyboard()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func onViewState(_ viewState: EditProfileViewState) {
        switch viewState {
        case .initial(let firstname, let lastname, let photoURL):
            loadingView.alpha = 0
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
            self.editImageButton.setImage(editImage, for: .normal)
        case .contentLoadingError:
            self.saveButton.isEnabled = false
            self.activityIndicator.stopAnimating()
            self.editImageButton.setImage(errorImage, for: .normal)
            self.editImageButton.alpha = 1
        case .loading:
            isLoadingShowing = true
        case .failure:
            isLoadingShowing = false
            let alert = UIAlertController(
                title: appDesignSystem.strings.editProfileErrorTitle,
                message: appDesignSystem.strings.editProfileErrorSubtitle,
                preferredStyle: .alert
            )
            alert.addAction(.cancelAction())
            self.present(alert, animated: true)
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
        navigationItem.leftBarButtonItem = backButton
        
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
        closeKeyboard()
        viewModel.onViewEvent(.saveButtonDidTapped)
    }
    
    @objc
    private func backTapped() {
        viewModel.onViewEvent(.onBack)
    }
    
    @objc
    private func closeKeyboard() {
        nameInputField.resignFirstResponder()
        surnameInputField.resignFirstResponder()
    }}

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
