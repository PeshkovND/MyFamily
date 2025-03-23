//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension AddFamilyViewController {

    final class ContentView: BaseView {
    
        private(set) lazy var backgroundImageView: UIImageView = {
            let view = UIImageView(image: icons.signInBackground)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            return view
        }()
        
        private(set) lazy var container: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = colors.backgroundPrimary
            view.clipsToBounds = true
            view.layer.cornerRadius = 28
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return view
        }()
        
        private(set) lazy var addFamilyButton: ActionButton = {
            
            var filled = UIButton.Configuration.filled()
            filled.title = "Create family"
            filled.imagePlacement = .leading
            filled.imagePadding = 4
            
            let button = ActionButton(configuration: filled, primaryAction: nil)
            
            return button
        }()
        
        private(set) lazy var enterFamilyNameTitle: UILabel = {
            let label = UILabel()
            label.text = "Enter the family name"
            label.font = typography.headline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            
            return label
        }()
        
        private(set) lazy var enterHomeAddressTitle: UILabel = {
            let label = UILabel()
            label.text = "Enter home address"
            label.font = typography.headline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            
            return label
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
        
        private(set) var addressInputField: TextFieldWithInsets = {
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
        
        private(set) lazy var stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16 // Отступ между элементами
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        private(set) lazy var backButton: ActionButton = {
            let button = ActionButton(type: .system)
            button.setTitle("Back", for: .normal)
            button.tintColor = .black
            button.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(systemName: "chevron.backward")
            button.setImage(image, for: .normal)
            return button
        }()
        
        private(set) lazy var loadingView: UIView = {
            return LoadingView()
        }()
        
        // swiftlint:disable function_body_length
        override func setLayout() {

            addSubview(backgroundImageView)
            addSubview(container)
            addSubview(loadingView)
            container.addSubview(backButton)
            container.addSubview(stack)
            stack.addArrangedSubview(enterFamilyNameTitle)
            stack.addArrangedSubview(nameInputField)
            stack.addArrangedSubview(enterHomeAddressTitle)
            stack.addArrangedSubview(addressInputField)
            stack.addArrangedSubview(addFamilyButton)
            
            loadingView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            backgroundImageView.snp.makeConstraints {
                $0.top.equalTo(0)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.height.equalToSuperview().multipliedBy(0.39)
            }
            
            container.snp.makeConstraints {
                $0.top.equalTo(backgroundImageView.snp.bottom).inset(28)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.bottom.equalToSuperview()
            }
            
            backButton.snp.makeConstraints {
                $0.top.equalTo(container.snp.top).inset(16)
                $0.leading.equalTo(container.snp.leading).inset(16)
                $0.height.equalTo(48)
            }
            
            stack.snp.makeConstraints {
                $0.top.equalTo(backButton.snp.bottom).inset(-4) // Отступ сверху
                $0.leading.equalTo(container.snp.leading).inset(16)
                $0.trailing.equalTo(container.snp.trailing).inset(16)
                $0.bottom.lessThanOrEqualTo(container.snp.bottom).inset(32) // Отступ снизу
            }
            
            addFamilyButton.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            
            nameInputField.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            
            addressInputField.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
        // swiftlint:enable function_body_length
    }
}
