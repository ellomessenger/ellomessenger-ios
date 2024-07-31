//
//  ChangeEmailViewController.swift
//  _idx_ELProfileUI_38A39E7F_ios_min11.0
//
//

import UIKit
import ELBase

class ChangeEmailViewController: BaseViewController {
    
    // MARK: - Public
    
    var onTapHelpSupport: VoidClosure?
    var onTapChangeEmailTo: EventClosure<String>?
    var onCheckPassword: EventClosure<String>?
    
    // MARK: - Lifecycle
    
    override func localize() {
        titleL?.text = Localization.changeEmail.localized(bundle)
        inputTF?.placeholder = Localization.newEmailAddress.localized(bundle)
        changeBtn?.setTitle(Localization.change.localized(bundle), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accessoryBtn?.isHidden = true
        inputTF?.isSecureTextEntry = false
        checkEmail()
        inputTF?.becomeFirstResponder()
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var inputTF: UITextField?
    
    @IBOutlet private weak var accessoryBtn: UIButton?
    
    @IBOutlet private weak var changeBtn: UIButton?
    
    private let bundle: Bundle = Bundle(for: ChangeEmailViewController.self)
    private let eyeImg = UIImage(named: "eye", in: Bundle(for: ChangeEmailViewController.self), compatibleWith: nil)
    private let eyeSlashImg = UIImage(named: "eye-slash", in: Bundle(for: ChangeEmailViewController.self), compatibleWith: nil)
    
    private func checkEmail() {
        changeBtn?.isEnabled = inputTF?.text?.isValidEmail() ?? false
        changeBtn?.backgroundColor = (inputTF?.text?.isValidEmail() ?? false) ? UIColor(hex: 0x0a49a5) : UIColor(hex: 0xcfcfd2)
    }
}

// MARK: - Actions

extension ChangeEmailViewController {
    
    @IBAction private func textFieldDidChange(_ sender: AnyObject?) {
        checkEmail()
    }
    
    @IBAction private func accessoryBtnDidTap(_ sender: AnyObject?) {
        inputTF?.isSecureTextEntry.toggle()
        let img = inputTF?.isSecureTextEntry ?? false ? eyeSlashImg : eyeImg
        accessoryBtn?.setImage(img, for: .normal)
    }
    
    @IBAction private func stageBtnDidTap(_ sender: AnyObject?) {
        guard let text = inputTF?.text else {
            return
        }
        onTapChangeEmailTo?(text)
    }
    
    @IBAction private func helpSupportBtnDidTap(_ sender: AnyObject?) {
        onTapHelpSupport?()
    }
}

private enum Localization: String {
    case changeEmail
    case password
    case newEmailAddress
    case next
    case change
}

