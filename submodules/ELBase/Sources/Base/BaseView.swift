
import Foundation
import UIKit

open class BaseView: UIView {

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initializeSubviews()
        localize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
        localize()
    }
    
    open func localize() {
        
    }

    open func initializeSubviews() {
        let ident:String = "\(self.classForCoder)".components(separatedBy: ".").last!
        let view: UIView = Bundle(for: self.classForCoder).loadNibNamed(ident, owner: self, options: nil)![0] as! UIView
        self.backgroundColor = .clear
        self.addSubviewWithSameSize(view)
        self.frame = view.bounds
    }
}
