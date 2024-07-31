import UIKit

@IBDesignable
public class DesignableUITextField: UITextField {
    
    @IBInspectable public var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable public var leftPadding: CGFloat = 0
    
    @IBInspectable public var color: UIColor? = UIColor.inputDefaultLight {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        guard let color else { return }
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.textRect(forBounds: bounds)
            let textPadding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
            return rect.inset(by: textPadding)
        }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
            let rect = super.editingRect(forBounds: bounds)
            let textPadding = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
            return rect.inset(by: textPadding)
        }
}

extension UIColor {
    static let inputDefaultLight = UIColor(named: "InputDefaultLight", in: Bundle(for: DesignableUITextField.self), compatibleWith: nil)
}
