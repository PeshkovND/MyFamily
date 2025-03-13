//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension AddFamilyForkViewController {
    
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
        
        private(set) lazy var createFamilyButton: ActionButton = {
            var filled = UIButton.Configuration.filled()
            filled.title = "Create a new family"
            
            let button = ActionButton(configuration: filled, primaryAction: nil)
            return button
        }()
        
        private(set) lazy var enterExistFamilyButton: ActionButton = {
            var filled = UIButton.Configuration.filled()
            filled.title = "Join an existing family"
            
            let button = ActionButton(configuration: filled, primaryAction: nil)
            return button
        }()
        
        
        private(set) lazy var logOutButton: ActionButton = {
            var filled = UIButton.Configuration.filled()
            filled.title = "Log out" // Системная иконка
            filled.imagePlacement = .leading
            filled.imagePadding = 4
            
            let button = ActionButton(configuration: filled, primaryAction: nil)
            button.setImage(UIImage(systemName: "door.right.hand.open"), for: .normal)
            return button
        }()
        
        private(set) lazy var title: UILabel = {
            
            let label = UILabel()
            label.font = typography.headline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        private(set) lazy var subtitle: UILabel = {
            let label = UILabel()
            label.text = "It looks like you haven't joined any family yet."
            label.font = typography.subheadline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()

        private(set) lazy var stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 16 // Отступ между элементами
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        override func setLayout() {
            addSubview(backgroundImageView)
            addSubview(container)
            container.addSubview(stack)

            // Добавляем элементы в stack
            stack.addArrangedSubview(title)
            stack.addArrangedSubview(subtitle)
            stack.addArrangedSubview(createFamilyButton)
            stack.addArrangedSubview(enterExistFamilyButton)
            stack.addArrangedSubview(logOutButton)
            
            // Констрейнты для backgroundImageView
            backgroundImageView.snp.makeConstraints {
                $0.top.equalTo(0)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.height.equalToSuperview().multipliedBy(0.39)
            }
            
            // Констрейнты для container
            container.snp.makeConstraints {
                $0.top.equalTo(backgroundImageView.snp.bottom).inset(28)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.bottom.equalToSuperview()
            }
            
            // Констрейнты для stack
            stack.snp.makeConstraints {
                $0.top.equalTo(container.snp.top).inset(32) // Отступ сверху
                $0.leading.equalTo(container.snp.leading).inset(16)
                $0.trailing.equalTo(container.snp.trailing).inset(16)
                $0.bottom.lessThanOrEqualTo(container.snp.bottom).inset(32) // Отступ снизу
            }
            
            // Констрейнты для кнопок
            createFamilyButton.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            
            enterExistFamilyButton.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            
            logOutButton.snp.makeConstraints {
                $0.height.equalTo(48)
            }
        }
    }
}
