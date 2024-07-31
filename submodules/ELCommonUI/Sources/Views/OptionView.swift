//
//  OptionView.swift
//  _idx_AccountContext_08074F76_ios_min11.0
//
//

import UIKit
import ELBase

public class OptionView: BaseView {
    
    public var onSelect: ((Option?)->())?
    
    public var option: Option? {
        didSet { setupOption() }
    }
    
    @IBOutlet private weak var iconIV: UIImageView?
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var containerStackView: UIStackView?
    @IBOutlet private weak var iconWidthLC: NSLayoutConstraint?
    @IBOutlet private weak var iconHeightLC: NSLayoutConstraint?
    @IBOutlet private weak var containerStackViewHeight: NSLayoutConstraint?
    
    @IBOutlet private weak var accessoryValueL: UILabel?
    @IBOutlet private weak var accessoryIconIV: UIImageView?
    @IBOutlet private weak var separatorV: UIView?
    
    private var shape: Shape = .square(32)
    private var showAccessory: Bool = true
    private var additionalValue: String = ""
    private var titleColor: UIColor = .black
    private var titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    private var additionalColor: UIColor = .black
    private var additionalFont: UIFont = .systemFont(ofSize: 14)
    private var accessoryImage: UIImage? = UIImage(named: "ELCommon/arrowRight-gray", in: Bundle(for: OptionView.self), compatibleWith: nil)
    private var showSeparator: Bool = true
    
    
    convenience public  init(option:Option, iconShape: Shape = .square(32), showAccessory: Bool = true, accessoryIcon:UIImage? = nil, additional: String = "",
                     titleColor: UIColor = .black, titleFont: UIFont = .systemFont(ofSize: 16), additionalColor: UIColor = .gray, additionalFont: UIFont = .systemFont(ofSize: 14), showSeparator: Bool = true) {
        self.init()
        self.shape = iconShape
        self.option = option
        self.showAccessory = showAccessory
        self.additionalValue = additional
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.additionalColor = additionalColor
        self.additionalFont = additionalFont
        if let ai = accessoryIcon {
            accessoryImage = ai
        }
        self.showSeparator = showSeparator
        
        setupOption()
    }
    
        
    private func setupOption() {
        iconIV?.image = option?.icon
        
        titleL?.text = option?.title
        titleL?.textColor = titleColor
        titleL?.font = titleFont
        
        iconIV?.isHidden = option?.icon == nil
        
        accessoryValueL?.text = additionalValue
        accessoryValueL?.textColor = additionalColor
        accessoryValueL?.font = additionalFont
        
        accessoryIconIV?.isHidden = !showAccessory
        accessoryIconIV?.image = self.accessoryImage
        
        switch shape {
            case let .square(size):
                iconWidthLC?.constant = size
                iconHeightLC?.constant = size
            case let .sized(w: w, h: h):
                iconWidthLC?.constant = w
                iconHeightLC?.constant = h
        }
        separatorV?.isHidden = !showSeparator
        if option?.isHeader ?? false {
            containerStackView?.layoutMargins.top = 36
        }
    }
    
    @IBAction private func onActionBtnDidTap(_ sender: AnyObject?) {
        onSelect?(option)
    }
}
 

public extension OptionView {
    
    struct Option {
        public var icon: UIImage?
        public var title: String = ""
        public var isHeader = false
        
        public init(icon: UIImage? = nil, title: String, isHeader: Bool = false) {
            self.icon = icon
            self.title = title
            self.isHeader = isHeader
        }
    }
    
    enum Shape {
        case square(CGFloat)
        case sized(w:CGFloat, h:CGFloat)
    }
}
