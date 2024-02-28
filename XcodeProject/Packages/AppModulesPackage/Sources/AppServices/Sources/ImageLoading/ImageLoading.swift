//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SDWebImage
import SDWebImageWebPCoder

// INFO:
// There is an issue with using it in non app target like `UtilityKit`.
// Specifically the issue is occured in AppCore module
// with description: No such module 'SDWebImage'
// It looks like there is no generated `swiftmodule` files in addition to object module file.
// Thus, it's used in app target as fallback for getting Image Loading functions.

public struct ImageLoadingHelper {

    public static func enableWebPCoder() {
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared) // swiftlint:disable:this explicit_singleton

        // Based on: https://github.com/SDWebImage/SDWebImageWebPCoder#modify-http-accept-header
        SDWebImageDownloader.shared.setValue( // swiftlint:disable:this explicit_singleton
            "image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept"
        )
    }

    private init() {}
}

extension UIImageView {

    public typealias ImageLoadingCompletion = (UIImage?, Error?, URL?) -> Void

    /// Load image with an `url` and `placeholder` to the imageView. If download fails then `errorImage`  is set to the imageView
    ///
    /// The download is asynchronous and cached.
    /// - Parameter url: The url for the image.
    /// - Parameter placeholderImage: The image to be set initially, until the image request finishes.
    /// - Parameter errorImage: The image to be set when image request finishes with error.
    /// - Parameter completion:
    ///       A closure which will be, in a case when `url` points to local image, called immediately after trying to load and set image,
    ///       or in a case when `url` points to remote image, called after trying to load and set remote image (successfully or not).
    public func loadImage(
        with url: URL?,
        placeholderImage: UIImage? = nil,
        errorImage: UIImage? = nil,
        completion: ImageLoadingCompletion? = nil
    ) {
        if let url = url, url.isFileURL {
            loadAssetImage(with: url, completion: completion)
        } else {
            loadRemoteImage(with: url, placeholderImage: placeholderImage, errorImage: errorImage, completion: completion)
        }
    }

    public func loadImage(
        with url: String?,
        placeholderImage: UIImage? = nil,
        errorImage: UIImage? = nil,
        completion: ImageLoadingCompletion? = nil
    ) {
        loadImage(
            with: URL(string: url ?? ""),
            placeholderImage: placeholderImage,
            errorImage: errorImage,
            completion: completion
        )
    }

    private func loadAssetImage(with url: URL, completion: ImageLoadingCompletion? = nil) {
        let imageName = url.lastPathComponent
        if let image = UIImage(named: imageName) {
            self.image = image
            completion?(image, nil, url)
        } else {
            completion?(nil, ImageLoadingError.assetNotFound(name: imageName), url)
        }
    }

    private func loadRemoteImage(
        with url: URL?,
        placeholderImage: UIImage? = nil,
        errorImage: UIImage? = nil,
        completion: ImageLoadingCompletion? = nil
    ) {
        sd_setImage(
            with: url,
            placeholderImage: placeholderImage
        ) { [weak self] image, error, cacheType, originalUrl in

            guard let self = self else { return }

            if let error = error {
                let errorDescription = """
                    image: \(String(describing: image)),
                       error: \(String(describing: error)),
                       cacheType: \(cacheType.rawValue),
                       originalUrl: \(String(describing: originalUrl))
                    """
                Self.logger.error(message: errorDescription)

                // Workaround for handling image loading cancelation. Maybe race conditions?
                if (error as NSError).code != SDWebImageError.cancelled.rawValue {
                    self.image = errorImage
                }
            }

            completion?(image, error, originalUrl)
        }
    }
}

// MARK: - Error & Logging
private extension UIImageView {

    private static var logger = LoggerFactory.make(
        config: .init(
            subsystemName: "ImageLoading",
            subsystemId: "app.imageLoading",
            category: "ImageLoading"
        )
    )

    private enum ImageLoadingError: LocalizedError {
        case assetNotFound(name: String)

        public var errorDescription: String? {
            switch self {
            case .assetNotFound(let name):
                return "Can't load asset image named: \(name)"
            }
        }
    }
}
