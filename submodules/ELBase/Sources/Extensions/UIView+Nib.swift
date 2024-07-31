
import UIKit

extension UIView {

    static func loadView() -> Self {
        if isNibExist() {
            return loadFromNib()
        } else {
            return self.init(frame: UIScreen.main.bounds)
        }
    }

    static func loadFromNib() -> Self {
        let selfClass: AnyClass = self as AnyClass
        var className = NSStringFromClass(selfClass)
        let bundle = Bundle(for: selfClass)
        
        if bundle.path(forResource: className, ofType: "nib") == nil {
            className = (className as NSString).pathExtension
            if bundle.path(forResource: className, ofType: "nib") == nil {
                fatalError("No xib file for view \(type(of: self))")
            }
        }
        return view(bundle, className: className)
    }
    
    @discardableResult
    func fromNib<T : UIView>(nibName: String? = nil) -> T? {
        let selfClass: AnyClass = type(of: self)
        let className = nibName ?? String(describing: selfClass)
        
        guard let view = Bundle(for: type(of: self)).loadNibNamed(className, owner: self, options: nil)?.first as? T else {
            return nil
        }
        addSubviewWithSameSize(view)
        return view
    }
}

// MARK: - Private Methods

private extension UIView {
    
    private static func isNibExist() -> Bool {
        let selfClass: AnyClass = self as AnyClass
        var className = NSStringFromClass(selfClass)
        let bundle = Bundle(for: selfClass)

        if bundle.path(forResource: className, ofType: "nib") == nil {
            className = (className as NSString).pathExtension
            if bundle.path(forResource: className, ofType: "nib") == nil {
                return false
            }
        }
        return true
    }
    
    private static func view<T: UIView>(_ bundle: Bundle, className: String) -> T {
        guard let nibContents = bundle.loadNibNamed(className, owner: nil, options: nil)
            else { fatalError("No xib file for view \(className)") }

        guard let view = nibContents.first(where: { ($0 as AnyObject).isKind(of: self) }) as? T
            else { fatalError("Xib doesn't have a view of such class \(self)") }
        return view
    }
    
}
