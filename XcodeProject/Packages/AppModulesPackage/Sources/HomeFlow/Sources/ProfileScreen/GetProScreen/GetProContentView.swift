import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow
import AppDesignSystem
import Utilities

extension GetProViewController {

    final class ContentView: BaseView {
        
        private(set) lazy var stackView: UIStackView = {
            let view = UIStackView()
            view.axis = .vertical
            view.alignment = .center
            view.spacing = 24
            view.distribution = .equalSpacing
            return view
        }()
        
        private(set) lazy var header: UILabel = {
            let view = UILabel()
            view.font = appDesignSystem.typography.headline
            view.text = appDesignSystem.strings.getProHeader
            view.numberOfLines = 0
            view.textAlignment = .center
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "crown")?.withTintColor(.orange)
            
            let text = NSMutableAttributedString(string: appDesignSystem.strings.getProHeader + " ")
            text.append(NSAttributedString(attachment: imageAttachment))
            view.attributedText = text
            
            return view
        }()
        
        private(set) lazy var firstAdvantageLabel: UILabel = {
            let view = UILabel()
            view.font = appDesignSystem.typography.body
            view.text = appDesignSystem.strings.getProFirstAdvantage
            view.numberOfLines = 0
            return view
        }()
        
        private(set) lazy var secondAdvantageLabel: UILabel = {
            let view = UILabel()
            view.font = appDesignSystem.typography.body
            view.text = appDesignSystem.strings.getProSecondAdvantage
            view.numberOfLines = 0
            return view
        }()
        
        private(set) lazy var buyButton: ActionButton = {
            let view = ActionButton()
            view.titleFont = appDesignSystem.typography.body
            view.setTitle(appDesignSystem.strings.getProBuy, for: .normal)
            view.backgroundColor = appDesignSystem.colors.backgroundSecondaryVariant
            view.layer.cornerRadius = 24
            return view
        }()
        
        private(set) lazy var closeButton: ActionButton = {
            let view = ActionButton()
            let image = UIImage(systemName: "xmark")?
                .withTintColor(
                    appDesignSystem.colors.backgroundSecondaryVariant,
                    renderingMode: .alwaysOriginal
                )
                .scaleImageToFitSize(size: .init(width: 20, height: 20))
            
            view.setImage(image, for: .normal)
            return view
        }()
        
        private(set) lazy var restorePurchaseButton: ActionButton = {
            let view = ActionButton()
            view.setTitle(appDesignSystem.strings.getProRestorePurchases, for: .normal)
            view.setTitleColor(.black, for: .normal)
            return view
        }()
        
        private(set) lazy var activityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = appDesignSystem.colors.labelPrimary
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            return activityIndicator
        }()
        
        private(set) lazy var purchaseProgressActivityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = appDesignSystem.colors.backgroundPrimary
            activityIndicator.stopAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            return activityIndicator
        }()


        override func setLayout() {
            addSubview(stackView)
            addSubview(closeButton)
            addSubview(activityIndicator)
            
            stackView.addArrangedSubview(header)
            stackView.addArrangedSubview(firstAdvantageLabel)
            stackView.addArrangedSubview(secondAdvantageLabel)
            stackView.addArrangedSubview(buyButton)
            stackView.addArrangedSubview(restorePurchaseButton)
            
            buyButton.addSubview(purchaseProgressActivityIndicator)
            setupConstraints()
        }
        
        private func setupConstraints() {
            stackView.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.center.equalToSuperview()
            }
            
            buyButton.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(64)
            }
            
            closeButton.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.top.equalToSuperview()
                $0.height.equalTo(48)
                $0.width.equalTo(48)
            }
            
            activityIndicator.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            purchaseProgressActivityIndicator.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}
