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
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
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
        }
    }
    
    @objc func  keyboardWillHide(_ notification: Notification) {
        
    }
    
    override func onViewState(_ viewState: EditProfileViewState) {
        switch viewState {
        case .initial:
            break
        case .imageloading:
            break
        case .imageLoaded:
            break
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
    }
    
    @objc
    private func closeKeyboard() {
        //        textView.resignFirstResponder()
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
                }
            }
        }
    }
}
