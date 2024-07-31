//
//  ELLoginTypesDescriptionContoller.swift
//  _idx_AccountContext_5A7F0606_ios_min15.4
//
//  Created by MacBookAir on 01.08.2023.
//

import UIKit
import ELBase

class ELLoginTypesDescriptionContoller: BaseViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let textFont = UIFont.systemFont(ofSize: 16.0)
    }
    
    @IBOutlet private weak var personalAccountLabel: UILabel!
    @IBOutlet private weak var businessAccountLabel: UILabel!
    @IBOutlet private weak var personalAccountDescriptionLabel: UILabel!
    @IBOutlet private weak var businessAccountDescriptionLabel: UILabel!
    @IBOutlet private weak var personalAccountTextView: UITextView! {
        didSet {
            personalAccountTextView.textContainer.lineFragmentPadding = 15.0
            personalAccountTextView.textContainerInset.top = 5.0
        }
    }
    @IBOutlet private weak var businessAccountTextView: UITextView! {
        didSet {
            businessAccountTextView.textContainer.lineFragmentPadding = 15.0
            businessAccountTextView.textContainerInset.top = 5.0
        }
    }
    
    // MARK: - Lifecycle
    override func storyboardName() -> String {
        return "WelcomeUI"
    }
    
    override func localize() {
        personalAccountLabel.text = "personalAccount".localized
        businessAccountLabel.text = "businessAccount".localized
        personalAccountDescriptionLabel.attributedText = NSAttributedString(
            string: "personalAccountDescription".localized,
            attributes: textAttributes()
        )
        
        let bulletStrings = ["personalAccountDescriptionOne".localized,
                             "personalAccountDescriptionTwo".localized,
                             "personalAccountDescriptionThree".localized,
                             "personalAccountDescriptionFour".localized,
                             "personalAccountDescriptionFive".localized,
                             "personalAccountDescriptionSix".localized,
                             "personalAccountDescriptionSeven".localized,
                             "personalAccountDescriptionEight".localized]
        let personalBulletPointedAttributedString = NSAttributedString(string: "")
            .bulletPointAttributedString(
                strings: bulletStrings,
                textFont: Constants.textFont,
                headIndent: 15.0)
        personalAccountTextView.attributedText = personalBulletPointedAttributedString
        
        businessAccountDescriptionLabel.attributedText = NSAttributedString(
            string: "businessAccountDescription".localized,
            attributes: textAttributes()
        )
        
        let businessBulletStrings = [
            "businessAccountDescriptionOne".localized,
            "businessAccountDescriptionTwo".localized,
            "businessAccountDescriptionThree".localized,
            "businessAccountDescriptionFour".localized,
            "businessAccountDescriptionFive".localized,
            "businessAccountDescriptionSix".localized,
            "businessAccountDescriptionSeven".localized,
            "businessAccountDescriptionEight".localized,
            "businessAccountDescriptionNine".localized,
            "businessAccountDescriptionTen".localized]
        let businessBulletPointedAttributedString = NSAttributedString(string: "")
            .bulletPointAttributedString(
                strings: businessBulletStrings,
                textFont: Constants.textFont,
                headIndent: 15.0)
        businessAccountTextView.attributedText = businessBulletPointedAttributedString
    }
    
    private func textAttributes() -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        
        let color = UIColor(bundleColorName: "TextDark") ?? .black
        
        return [.paragraphStyle: paragraphStyle,
                .foregroundColor: color]
    }
}
