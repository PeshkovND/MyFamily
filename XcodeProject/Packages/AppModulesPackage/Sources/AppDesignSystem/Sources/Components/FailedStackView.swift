import UIKit

public class FailedStackView: UIStackView {
    
    private(set) lazy var loadingErrorTitle: UILabel = {
        let view = UILabel()
        view.font = appDesignSystem.typography.headline
        view.numberOfLines = 0
        view.textAlignment = .center
        
        return view
    }()
    
    private(set) lazy var loadingErrorSubtitle: UILabel = {
        let view = UILabel()
        view.font = appDesignSystem.typography.body
        view.numberOfLines = 0
        view.textAlignment = .center
        
        return view
    }()
    
    public init(title: String, subtitle: String) {
        super.init(frame: .zero)
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 24
        self.distribution = .equalSpacing
        self.alpha = 0
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = appDesignSystem.icons.error
        
        let text = NSMutableAttributedString(string: title + " ")
        text.append(NSAttributedString(attachment: imageAttachment))
        loadingErrorTitle.attributedText = text
        
        loadingErrorSubtitle.text = subtitle
        
        self.addArrangedSubview(loadingErrorTitle)
        self.addArrangedSubview(loadingErrorSubtitle)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
