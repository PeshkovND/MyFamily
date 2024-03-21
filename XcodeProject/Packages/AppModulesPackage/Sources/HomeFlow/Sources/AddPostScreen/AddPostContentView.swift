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
            
            view.text = strings.postScreenCommentPlaceholder
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
            let image = UIImage(systemName: "music.note")?.withTintColor(
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
        
        override func setLayout() {
            addSubview(addMediaContainer)
            addSubview(textView)
            addMediaContainer.addSubview(sendButton)
            addMediaContainer.addSubview(addAudioButton)
            addMediaContainer.addSubview(addPhotoButton)
            addMediaContainer.addSubview(addVideoButton)
            
            setupConstraints()
        }
        
        func setupConstraints() {
            addMediaContainer.snp.makeConstraints {
                $0.height.equalTo(54)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            }
            
            sendButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(4)
                $0.height.equalTo(54)
                $0.width.equalTo(54)
            }
            
            textView.snp.makeConstraints {
                $0.bottom.equalTo(addMediaContainer.snp.top)
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.leading.equalToSuperview().inset(8)
                $0.trailing.equalToSuperview().inset(8)
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
