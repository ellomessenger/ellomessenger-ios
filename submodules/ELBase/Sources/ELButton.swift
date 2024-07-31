//
//  ELButton.swift
//  _idx_AccountContext_96ECB18F_ios_min15.4
//

import UIKit
import Foundation

private struct BackgroundColor {
    let normal: UIColor?
    let disabled: UIColor?
}

private struct TextColor {
    let normal: UIColor?
    let disabled: UIColor?
}

public enum ELButtonStyle {
    case blue
    case white
    
    fileprivate var hasBorder: Bool {
        self == .white
    }
    
    fileprivate var setFont: UIFont? {
        switch self {
        case .blue:
            return .systemFont(ofSize: 15, weight: .medium)
        case .white:
            return .systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    fileprivate var background: BackgroundColor {
        switch self {
        case .blue:
            return BackgroundColor(normal: .blueButton, disabled: .darkGrayButton)
        case .white:
            return BackgroundColor(normal: .white, disabled: .white)
        }
    }
    
    fileprivate var textColor: TextColor {
        switch self {
        case .blue:
            return TextColor(normal: .white, disabled: .textGray)
        case .white:
            return TextColor(normal: .textDark, disabled: .textGray)
        }
    }
    
    fileprivate var borderColor: CGColor {
        switch self {
        case .blue:
            return UIColor.clear.cgColor
        case .white:
            return UIColor.darkGrayButton.cgColor
        }
    }
}

@IBDesignable
final public class ELButton: UIButton {
    var defaultCornerRadius: CGFloat = 18.0
    var style: ELButtonStyle = .white {
        didSet {
            setupStyle(style)
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            setEnabled()
        }
    }
       
    // MARK: - Init
    init(_ style: ELButtonStyle = .white) {
        super.init(frame: .zero)
        self.style = style
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup
    private func setup() {
        isEnabled = false
        clipsToBounds = true
        layer.cornerRadius = defaultCornerRadius
    }
    
    private func setupStyle(_ style: ELButtonStyle) {
        titleLabel?.font = style.setFont ?? UIFont.systemFont(ofSize: 16.0)
        setTextColor()
        setBackground()
        layer.borderWidth = isEnabled && style.hasBorder ? 1.0 : 0.0
        layer.borderColor = style.borderColor
    }
    
    private func setTextColor() {
        setTitleColor(style.textColor.normal, for: .normal)
        setTitleColor(style.textColor.disabled, for: .disabled)
    }
    
    private func setBackground() {
        backgroundColor = isEnabled ? style.background.normal: style.background.disabled
    }
    
    private func setEnabled() {
        layer.borderWidth = isEnabled && style.hasBorder ? 1.0 : 0.0
        backgroundColor = isEnabled ? style.background.normal : style.background.disabled
    }
    
// MARK: - Public
    public func apply(style: ELButtonStyle) {
        setupStyle(style)
    }
}

// MARK: - Colors
private extension UIColor {
    static let blueButton = UIColor(red: 0.039, green: 0.286, blue: 0.647, alpha: 1)
    static let darkGrayButton = UIColor(red: 0.812, green: 0.812, blue: 0.824, alpha: 1)
    static let textDark = UIColor(red: 0.027, green: 0.027, blue: 0.031, alpha: 1)
    static let textGray = UIColor(red: 0.573, green: 0.573, blue: 0.596, alpha: 1)
}
