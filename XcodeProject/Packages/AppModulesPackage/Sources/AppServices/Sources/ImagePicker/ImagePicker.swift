//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

public final class ImagePicker: NSObject {

    private static var logger = LoggerFactory.default

    public static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    @Published public var selectedImage: UIImage?

    public func showCameraViewController(in hostViewController: UIViewController) {
        hostViewController.present(makeCameraViewController(), animated: true)
    }

    public func showPhotoLibraryViewController(in hostViewController: UIViewController) {
        hostViewController.present(makePhotoLibraryViewController(), animated: true)
    }

    private func makeCameraViewController() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.cameraDevice = .front
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        return imagePickerController
    }

    private func makePhotoLibraryViewController() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        return imagePickerController
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            Self.logger.warning(
                message: "Edited Image cannot be provided from picker"
            )
            return
        }

        selectedImage = image
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
