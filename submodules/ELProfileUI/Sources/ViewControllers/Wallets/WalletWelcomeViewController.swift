//
//  WalletWelcomeViewController.swift
//  ElloApp
//
//  Created by Damir Aushenov on 25/1/23.
//

import Foundation
import UIKit
import ELBase
import Display

class WalletWelcomeViewController: BaseViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let textFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    }
    
    // MARK: - Public
    public var onTapOption: VoidClosure?
    public var onTapDeleteAccount: VoidClosure?
    
    @IBAction func buttonTap(_ sender: Any) {
        activateButton.isEnabled = false
        onTapOption?()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {[weak self]in
//            self?.activateButton.isEnabled = true
//        })
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activateButton.apply(style: .blue)
    }
    
//    public static func wallets(onTapOption: VoidClosure?) -> ViewController {
//        let adopt = AdaptingController(viewController: nil)
//        if let vc = WalletWelcomeViewController.controller {
//            vc.onTapOption = {
//                onTapOption?()
//            }
//            vc.onTapBack = {
//                adopt.navigationController?.popViewController(animated: true)
//            }
//            adopt.altController = vc
//        }
//        return adopt
//    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var topUpMethodsLabel: UILabel!
    @IBOutlet private var payInfoLabel: UILabel!
    @IBOutlet private var cardInfoLabel: UILabel!
    @IBOutlet private var paypalInfoLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var methodsView: UIView!
    @IBOutlet var activateButton: ELButton!
    @IBOutlet private var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.textContainer.lineFragmentPadding = .zero
            descriptionTextView.textContainerInset = .zero
            descriptionTextView.contentInset = .zero
        }
    }
    
    struct Wallets {
        let title: String
        let icon: String
        let desc: String
        
        init(title: String, icon: String, desc: String) {
            self.title = title
            self.icon = icon
            self.desc = desc
        }
    }
    
    override func localize() {
        titleLabel.text = "Wallet.Welcome".localized
        payInfoLabel.text = "Wallet.Welcome.PayInfo".localized
        topUpMethodsLabel.text = "Wallet.Welcome.Methods".localized
        
        let bulletStrings = ["Wallet.Welcome.DescriptionOne".localized,
                             "Wallet.Welcome.DescriptionTwo".localized,
                             "Wallet.Welcome.DescriptionThree".localized]
//                           "Wallet.Welcome.DescriptionFour".localized,
//                           "Wallet.Welcome.DescriptionFive".localized]
        
        let bulletPointedAttributedString = NSAttributedString(string: "").bulletPointAttributedString(strings: bulletStrings, 
                                                                                                       textFont: Constants.textFont,
                                                                                                       headIndent: 15.0)

        descriptionTextView.attributedText = bulletPointedAttributedString
        cardInfoLabel.text = "Wallet.Welcome.Card".localized
        paypalInfoLabel.text = "Wallet.Welcome.Paypal".localized
    }
}

// MARK: - Actions

extension WalletWelcomeViewController {
    
    @IBAction private func deleteAccountBtnDidTap(_ sender: AnyObject?) {
        onTapDeleteAccount?()
    }
}
