//
//  AttributedText.swift
//  VideoConverter
//
//  Created by Evgeniy Makarov on 10.02.2023.
//

import Foundation
import UIKit

extension NSMutableAttributedString {

    convenience init (fullString: String, fullStringColor: UIColor, fullStringFont: UIFont, subString: String, subStringColor: UIColor, subStringFont: UIFont) {
           let rangeOfSubString = (fullString as NSString).range(of: subString)
           let rangeOfFullString = NSRange(location: 0, length: fullString.count)//fullString.range(of: fullString)
           let attributedString = NSMutableAttributedString(string:fullString)
           let fullStringAttributes: [NSAttributedString.Key: Any] = [
            .font: fullStringFont,
            .foregroundColor: fullStringColor,
           ]
           let rangeStringAttributes: [NSAttributedString.Key: Any] = [
            .font: subStringFont,
            .foregroundColor: subStringColor,
           ]
        
        attributedString.addAttributes(fullStringAttributes, range: rangeOfFullString)
        attributedString.addAttributes(rangeStringAttributes, range: rangeOfSubString)

           self.init(attributedString: attributedString)
   }
}

extension UITextView {
    
    func hyperLink(originalText: String, hyperLink: String, hyperLink2: String, urlString: String, urlString2: String) {

    let style = NSMutableParagraphStyle()
    style.alignment = .left

    let attributedOriginalText = NSMutableAttributedString(string: originalText)
    let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
    let linkRange2 = attributedOriginalText.mutableString.range(of: hyperLink2)
    let fullRange = NSMakeRange(0, attributedOriginalText.length)
    attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
    attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString2, range: linkRange2)
    attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: "070708") ?? .black, range: fullRange)
    attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.Custom.sfProText(ofSize: 14, weight: .regular), range: fullRange)

        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "070708") ?? .black,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: UIFont.Custom.sfProText(ofSize: 14, weight: .semibold),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ] as [NSAttributedString.Key : Any]
    self.attributedText = attributedOriginalText
    }
}
