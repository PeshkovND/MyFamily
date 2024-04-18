import UIKit
import SnapKit

public class LoadingView: UIView {
    
    private let container = {
        let container = UIView()
        container.backgroundColor = .black.withAlphaComponent(0.3)
        return container
    }()
    
    private let loadingStackView = {
        let loadingView = UIStackView()
        loadingView.axis = .horizontal
        loadingView.spacing = 8
        loadingView.backgroundColor = appDesignSystem.colors.backgroundPrimary
        loadingView.layer.cornerRadius = 12
        loadingView.alignment = .center
        loadingView.distribution = .equalCentering
        loadingView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        loadingView.isLayoutMarginsRelativeArrangement = true
        return loadingView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = appDesignSystem.colors.labelPrimary
        activityIndicator.startAnimating()
        
        return activityIndicator
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = appDesignSystem.strings.commonLoading
        label.textColor = appDesignSystem.colors.labelPrimary
        label.font = appDesignSystem.typography.body
        return label
    }()
    
    public init() {
        super.init(frame: .zero)
        backgroundColor = .black.withAlphaComponent(0.3)
        self.addSubview(loadingStackView)
        loadingStackView.addArrangedSubview(label)
        loadingStackView.addArrangedSubview(activityIndicator)
        
        loadingStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
