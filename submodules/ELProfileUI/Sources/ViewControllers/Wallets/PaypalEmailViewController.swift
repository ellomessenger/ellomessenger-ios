//
//  PaypalEmailViewController.swift
//  _idx_ELProfileUI_3A664715_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi
import ELCommonUI
import SwiftSignalKit

class PaypalEmailViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet private var payPalNavigationLabel: UILabel!
    
    // MARK: - Properties
    var onTapOption: EventClosure<String>?
    @IBOutlet private weak var emailTF: ValidationTextField?
    @IBOutlet private weak var connectButton: UIButton?
    
    public let getFullUserDisposable = MetaDisposable()
    
    public var email: String = "" {didSet{
        if emailTF?.textField.text != email {
            emailTF?.textField.text = email
        }
        
        self.connectButton?.isEnabled = self.emailTF?.isValid ?? false
    }}
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payPalNavigationLabel.text = "Wallets.PayPalTitle".localized
        emailTF?.validator = EmailValidator()
        emailTF?.setPlaceholder("emailAddress".localized, isRequired: false)
        connectButton?.isEnabled = false
        emailTF?.onTextChange = { [weak self] email, _ in
            self?.email = email ?? ""
        }
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    
    // MARK: - IBActions
    @IBAction func connectPaypalTapped(_ sender: UIButton) {
        onTapOption?(email)
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    
    // MARK: - Extensions
}


