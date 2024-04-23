import UIKit

public final class TextFieldWithInsets: UITextField {
    
    public var textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.textRect(forBounds: insetBounds)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.editingRect(forBounds: insetBounds)
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        return super.placeholderRect(forBounds: insetBounds)
    }
}
