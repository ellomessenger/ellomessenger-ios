//
//  BotRequestCountView.swift
//  _idx_ELCommonUI_F0C2D3F9_ios_min14.0
//
//

import UIKit
import ELBase

public class BotRequestCountView: BaseView {
    @IBOutlet private var titleTextView: UITextView?
    
    private lazy var gradientLayer = CAGradientLayer()
    
    public var buyMoreAction: VoidClosure?
    
    public override func initializeSubviews() {
        super.initializeSubviews()
        
        gradientLayer.colors = [UIColor(hex: 0x0E2B64).cgColor, UIColor(hex: 0x36BDFF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = bounds
        titleTextView?.isEditable = false
        titleTextView?.delegate = self
    }
    
    public func updateTitle(_ title: String, link: String?) {
        if let link {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attributedString = NSMutableAttributedString(string: title + link, attributes: [
                .foregroundColor: UIColor.hex(0xFFFFFF),
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .paragraphStyle: paragraph
            ])
//            let url = URL(string: "")!

            // Set the 'click here' substring to be the link
            attributedString.setAttributes([.link: ""], range: NSMakeRange(attributedString.length - link.count, link.count))

            titleTextView?.attributedText = attributedString
            titleTextView?.isUserInteractionEnabled = true

            // Set how links should appear: blue and underlined
            titleTextView?.linkTextAttributes = [
                .foregroundColor: UIColor.hex(0xFFFFFF),
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]        } else {
            titleTextView?.attributedText = nil
            titleTextView?.text = title
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        titleTextView?.centerVertically()
    }
}

extension BotRequestCountView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        buyMoreAction?()
        return false
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}

extension UITextView {
    func centerVertically() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }
}
