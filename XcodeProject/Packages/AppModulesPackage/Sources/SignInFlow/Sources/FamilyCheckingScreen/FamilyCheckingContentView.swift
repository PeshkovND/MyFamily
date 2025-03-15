//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension FamilyCheckingViewController {

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
        
        private(set) lazy var loadingView: UIView = {
            return LoadingView()
        }()
        
        // swiftlint:disable function_body_length
        override func setLayout() {

            addSubview(backgroundImageView)
            addSubview(container)
            addSubview(loadingView)
            
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
        }
        // swiftlint:enable function_body_length
    }
}
