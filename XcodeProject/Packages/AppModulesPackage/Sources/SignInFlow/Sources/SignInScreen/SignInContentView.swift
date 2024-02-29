//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension SignInViewController {

    final class ContentView: BaseView {
    
        private(set) lazy var backgroundImageView: UIImageView = {
            let view = UIImageView(image: icons.signInBackground)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            return view
        }()
        
        private(set) lazy var signInContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = colors.backgroundPrimary
            view.clipsToBounds = true
            view.layer.cornerRadius = 28
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return view
        }()
        
        private(set) lazy var signInButton: ActionButton = {
            
            var filled = UIButton.Configuration.filled()
            filled.title = strings.signInWithVk
            filled.imagePlacement = .leading
            filled.imagePadding = 4
            
            let button = ActionButton(configuration: filled, primaryAction: nil)
            let icon = icons.vkLogo.scaleImageToFitSize(size: CGSize(width: 40, height: 40))
            button.setImage(icon, for: .normal)
            
            return button
        }()
        
        private(set) lazy var title: UILabel = {
            let label = UILabel()
            label.text = strings.signInTitle
            label.font = typography.headline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            
            return label
        }()
        
        private(set) lazy var subtitle: UILabel = {
            let label = UILabel()
            label.text = strings.signInSubtitle
            label.font = typography.subheadline
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            
            return label
        }()

        // swiftlint:disable function_body_length
        override func setLayout() {

            addSubview(backgroundImageView)
            addSubview(signInContainer)
            signInContainer.addSubview(signInButton)
            signInContainer.addSubview(title)
            signInContainer.addSubview(subtitle)

            backgroundImageView.snp.makeConstraints {
                $0.top.equalTo(0)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.height.equalToSuperview().multipliedBy(0.39)
            }
            
            signInContainer.snp.makeConstraints {
                $0.top.equalTo(backgroundImageView.snp.bottom).inset(28)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.bottom.equalToSuperview()
            }
            
            signInButton.snp.makeConstraints {
                $0.centerY.equalTo(signInContainer.snp.centerY)
                $0.centerX.equalTo(signInContainer.snp.centerX)
                $0.height.equalTo(48)
            }
            
            title.snp.makeConstraints {
                $0.top.equalTo(signInContainer.snp.top).inset(32)
                $0.width.equalTo(signInContainer.snp.width).multipliedBy(0.8)
                $0.centerX.equalTo(signInContainer.snp.centerX)
            }
            
            subtitle.snp.makeConstraints {
                $0.top.equalTo(title.snp.bottom).inset(-16)
                $0.width.equalTo(signInContainer.snp.width).multipliedBy(0.8)
                $0.centerX.equalTo(signInContainer.snp.centerX)
            }
        }
        // swiftlint:enable function_body_length
    }
}
