//
//  ConfirmPasswordViewController.swift
//  _idx_ELProfileUI_72D2179B_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppCore
import ELCommonUI

public class ConfirmPasswordViewController: BaseViewController {
    public typealias Result = (email: String, password: String)
    
    // MARK: - Public
    
    var onTapConfirmPasswordTo: EventClosure<Result>?
    var onPasswordError: ErrorCallback?
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF?.onReturn = { [weak self] in
            self?.passwordTF?.textField.becomeFirstResponder()
        }
        
        passwordTF?.onReturn = { [weak self] in
            self?.passwordTF?.textField.resignFirstResponder()
        }
        passwordTF?.isSecure = true
    }
    
    public override func localize() {
        titleL?.text = Localization.title.localized(bundle)
        descriptionL?.text = Localization.description.localized(bundle)
        emailTF?.textField.placeholder = Localization.email.localized(bundle)
        passwordTF?.textField.placeholder = Localization.password.localized(bundle)
        deleteL?.text = Localization.deleteAccount.localized(bundle)
    }
    
    public override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var descriptionL: UILabel?
    
    @IBOutlet private weak var emailTF: ValidationTextField?
    
    @IBOutlet private weak var passwordTF: ValidationTextField?
    @IBOutlet private weak var scrollView: UIScrollView?
    
    @IBOutlet private weak var deleteBtn: UIButton?
    @IBOutlet private weak var deleteL: UILabel?
    
    private let bundle: Bundle = Bundle(for: ChangeEmailViewController.self)
    
}

// MARK: - Actions

extension ConfirmPasswordViewController {
    
    @IBAction private func deleteBtnDidTap(_ sender: AnyObject?) {
        guard let email = emailTF?.textField.text else {
            emailTF?.errorDescription = EmailValidator.Error.emptyEmailError.localizedDescription
            return
        }
        do {
            let emailValidator = EmailValidator()
            try emailValidator.validate(value: email)
        } catch {
            emailTF?.errorDescription = error.localizedDescription
        }
        
        guard let password = passwordTF?.textField.text else {
            passwordTF?.errorDescription = PasswordValidator.Error.emptyPasswordError.localizedDescription
            return
        }
        guard let isValidEmail = emailTF?.isValid, let isValidPassword = passwordTF?.isValid, isValidEmail && isValidPassword else {
            return
        }
        onTapConfirmPasswordTo?((email, password))
    }
}

private enum Localization: String {
    case email
    case password
    case title = "deleteYourAccoutTitle"
    case description = "deleteYourAccoutDescription"
    case deleteAccount = "deleteAccountBtn"
}
