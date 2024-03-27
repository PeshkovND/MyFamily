import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension EditProfileViewController {

    final class ContentView: BaseView {
        
        private(set) var scrollView: UIScrollView = {
            let view = UIScrollView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private(set) var contentContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private(set) var nameLabel: UILabel = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = appDesignSystem.typography.body
            view.text = appDesignSystem.strings.editProfileNameTitle
            view.textColor = appDesignSystem.colors.backgroundSecondaryVariant
            return view
        }()
        
        private(set) var userPhotoView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = 36
            view.backgroundColor = .red
            view.clipsToBounds = true
            view.isUserInteractionEnabled = true
            return view
        }()
        
        private(set) var surnameLabel: UILabel = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = appDesignSystem.typography.body
            view.text = appDesignSystem.strings.editProfileSurnameTitle
            view.textColor = appDesignSystem.colors.backgroundSecondaryVariant
            return view
        }()
        
        private(set) var nameInputField: TextFieldWithInsets = {
            let view = TextFieldWithInsets()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = appDesignSystem.typography.body
            view.layer.borderWidth = 1
            view.layer.borderColor = appDesignSystem.colors.labelPrimary.cgColor
            view.layer.cornerRadius = 12
            view.textInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
            view.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
            return view
        }()
        
        private(set) var editImageButton: ActionButton = {
            let view = ActionButton()
            let image = UIImage(systemName: "photo.badge.plus")?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
                .scaleImageToFitSize(size: .init(width: 32, height: 32))
            view.setImage(image, for: .normal)
            view.backgroundColor = .black.withAlphaComponent(0.5)
            view.showsMenuAsPrimaryAction = true
            return view
        }()
        
        private(set) var activityIndicator: UIActivityIndicatorView = {
            let view = UIActivityIndicatorView()
            view.color = .white
            view.backgroundColor = .black.withAlphaComponent(0.5)
            return view
        }()
        
        private(set) var surnameInputField: TextFieldWithInsets = {
            let view = TextFieldWithInsets()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = appDesignSystem.typography.body
            view.layer.borderWidth = 1
            view.layer.borderColor = appDesignSystem.colors.labelPrimary.cgColor
            view.layer.cornerRadius = 12
            view.textInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
            view.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
            return view
        }()
        
        override func setLayout() {
            addSubview(scrollView)
            scrollView.addSubview(contentContainer)
            contentContainer.addSubview(nameLabel)
            contentContainer.addSubview(surnameLabel)
            contentContainer.addSubview(nameInputField)
            contentContainer.addSubview(surnameInputField)
            contentContainer.addSubview(userPhotoView)
            userPhotoView.addSubview(editImageButton)
            userPhotoView.addSubview(activityIndicator)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            scrollView.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.bottom.equalToSuperview()
            }
            
            contentContainer.snp.makeConstraints {
                $0.top.equalTo(self.scrollView)
                $0.left.equalTo(self.scrollView)
                $0.width.equalTo(self.scrollView)
                $0.height.equalTo(self.scrollView)
            }
            
            setupUserPhotoConstraints()
            setupTextFieldsConstraints()
        }
        
        private func setupUserPhotoConstraints() {
            userPhotoView.snp.makeConstraints {
                $0.top.equalToSuperview().inset(16)
                $0.height.equalTo(72)
                $0.width.equalTo(72)
                $0.centerX.equalToSuperview()
            }
            
            editImageButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            activityIndicator.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        private func setupTextFieldsConstraints() {
            nameLabel.snp.makeConstraints {
                $0.top.equalTo(userPhotoView.snp.bottom).inset(-16)
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.centerX.equalToSuperview()
            }
            
            nameInputField.snp.makeConstraints {
                $0.top.equalTo(nameLabel.snp.bottom).inset(-4)
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(48)
            }
            
            surnameLabel.snp.makeConstraints {
                $0.top.equalTo(nameInputField.snp.bottom).inset(-8)
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.centerX.equalToSuperview()
            }
            
            surnameInputField.snp.makeConstraints {
                $0.top.equalTo(surnameLabel.snp.bottom).inset(-4)
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(48)
            }
        }

    }
}

class TextFieldWithInsets: UITextField {
    
    var textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.textRect(forBounds: insetBounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.editingRect(forBounds: insetBounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.placeholderRect(forBounds: insetBounds)
    }
}
