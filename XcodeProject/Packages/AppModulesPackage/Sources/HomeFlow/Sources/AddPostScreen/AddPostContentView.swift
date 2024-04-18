import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension AddPostViewController {

    final class ContentView: BaseView {

        private(set) lazy var textView: UITextView = {
            let view = UITextView()
            view.font = appDesignSystem.typography.body.withSize(16)
            view.tintColor = colors.backgroundSecondaryVariant
            view.translatesAutoresizingMaskIntoConstraints = true
            view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            view.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            view.text = strings.addPostScreenPlaceholder
            view.textColor = UIColor.lightGray
            
            return view
        }()
        
        private(set) lazy var sendButton: ActionButton = {
            let view = ActionButton()
            var image = UIImage(systemName: "arrow.forward.circle")?.withTintColor(
                colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            ).scaleImageToFitSize(
                size: .init(
                    width: 36,
                    height: 36
                )
            )
            view.setImage(image, for: .normal)
            
            return view
        }()
        
        private(set) lazy var addMediaContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private(set) lazy var deleteContentButton: ActionButton = {
            let view = ActionButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(systemName: "x.circle.fill")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            )
                .scaleImageToFitSize(size: .init(width: 32, height: 32))
            view.setImage(image, for: .normal)
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            view.layer.cornerRadius = 16
            view.backgroundColor = .white
            return view
        }()
        
        private(set) lazy var addPhotoButton: ActionButton = {
            let button = ActionButton()
            let image = UIImage(systemName: "photo")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            ).scaleImageToFitSize(
                size: .init(
                    width: 30,
                    height: 30
                )
            )
            button.showsMenuAsPrimaryAction = true
            button.setImage(image, for: .normal)
            return button
        }()
        
        private(set) lazy var activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView()
            indicator.color = .white
            indicator.backgroundColor = .black.withAlphaComponent(0.5)
            indicator.layer.cornerRadius = 8
            return indicator
        }()
        
        private(set) lazy var errorImageView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            view.contentMode = .center
            view.backgroundColor = .black.withAlphaComponent(0.5)
            view.alpha = 0
            
            let image = UIImage(systemName: "exclamationmark.triangle.fill")?
                .withTintColor(appDesignSystem.colors.backgroundPrimary,
                               renderingMode: .alwaysOriginal)
                .scaleImageToFitSize(size: .init(width: 36, height: 36))

            view.image = image
            return view
        }()
        
        private(set) lazy var loadingView: UIView = {
            return LoadingView()
        }()
        
        private(set) lazy var addVideoButton: ActionButton = {
            let button = ActionButton()
            let image = UIImage(systemName: "video")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            ).scaleImageToFitSize(
                size: .init(
                    width: 30,
                    height: 30
                )
            )
            button.showsMenuAsPrimaryAction = true
            button.setImage(image, for: .normal)
            return button
        }()
        
        private(set) lazy var addAudioButton: ActionButton = {
            let button = ActionButton()
            let image = UIImage(systemName: "mic")?.withTintColor(
                appDesignSystem.colors.backgroundSecondaryVariant,
                renderingMode: .alwaysOriginal
            ).scaleImageToFitSize(
                size: .init(
                    width: 30,
                    height: 30
                )
            )
            button.setImage(image, for: .normal)
            return button
        }()
        
        private(set) lazy var mediaContentContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = true
            return view
        }()
        
        private(set) lazy var contentImageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view
        }()
        
        private(set) lazy var contentAudioView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            view.contentMode = .center
            view.backgroundColor = appDesignSystem.colors.backgroundTertiary
            
            let image = UIImage(systemName: "music.note")?
                .withTintColor(appDesignSystem.colors.backgroundSecondaryVariant,
                               renderingMode: .alwaysOriginal)
                .scaleImageToFitSize(size: .init(width: 36, height: 36))

            view.image = image
            return view
        }()
        
        private(set) lazy var contentVideoView: VideoPlayerView = {
            let view = VideoPlayerView()
            view.backgroundColor = appDesignSystem.colors.labelPrimary
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view
        }()
        
        override func setLayout() {
            addSubview(addMediaContainer)
            addSubview(textView)
            addMediaContainer.addSubview(sendButton)
            addMediaContainer.addSubview(addAudioButton)
            addMediaContainer.addSubview(addPhotoButton)
            addMediaContainer.addSubview(addVideoButton)
            addSubview(mediaContentContainer)
            contentImageView.addSubview(deleteContentButton)
            contentVideoView.addSubview(deleteContentButton)
            contentAudioView.addSubview(deleteContentButton)
            addSubview(loadingView)
            setupConstraints()
        }
        
        func setupConstraints() {
            setupMediaConstraints()
        
            sendButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(4)
                $0.height.equalTo(54)
                $0.width.equalTo(54)
            }
            
            textView.snp.makeConstraints {
                $0.bottom.equalTo(mediaContentContainer.snp.top)
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.leading.equalToSuperview().inset(8)
                $0.trailing.equalToSuperview().inset(8)
            }
            
            loadingView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        private func setupMediaConstraints() {
            mediaContentContainer.snp.makeConstraints {
                $0.height.equalTo(0)
                $0.width.equalTo(80)
                $0.leading.equalToSuperview().inset(8)
                $0.bottom.equalTo(addMediaContainer.snp.top)
            }
            
            addMediaContainer.snp.makeConstraints {
                $0.height.equalTo(54)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            }
            
            addPhotoButton.snp.makeConstraints {
                $0.height.equalTo(54)
                $0.width.equalTo(54)
                $0.leading.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
            }
            
            addVideoButton.snp.makeConstraints {
                $0.height.equalTo(54)
                $0.width.equalTo(54)
                $0.leading.equalTo(addPhotoButton.snp.trailing).inset(8)
                $0.centerY.equalToSuperview()
            }
            
            addAudioButton.snp.makeConstraints {
                $0.height.equalTo(54)
                $0.width.equalTo(54)
                $0.leading.equalTo(addVideoButton.snp.trailing).inset(8)
                $0.centerY.equalToSuperview()
            }
        }
    }
}
