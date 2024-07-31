//
//  ELNewPasswordController.swift
//  _idx_ELWelcomeUI_D86C41EB_ios_min11.0
//
//

import UIKit
import ELBase
import ELCommonUI
import ElloAppCore

class ELNewPasswordController: BaseViewController {
    // MARK: - Public
    var onTapSend: EventClosure<String>?
    var onPasswordError: ErrorCallback?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardListener = KeyboardAppearListener(self)
        actionBtn.apply(style: .blue)
        checkActionButton()
    }
    
    override func storyboardName() -> String {
        return "WelcomeUI"
    }
    
    override func localize() {
        titleLabel?.text = Localization.newPasswordTitle.localized(Bundle(for: Self.self))
        subtitleLabel?.text = Localization.newPasswordSubtitle.localized(Bundle(for: Self.self))
        passwordTextField?.placeholder = Localization.newPassword.localized(Bundle(for: Self.self))
        confirmPasswordTextField?.placeholder = Localization.retypePassword.localized(Bundle(for: Self.self))
        actionBtn?.setTitle(Localization.save.localized(Bundle(for: Self.self)), for: .normal)
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var actionBtn: ELButton!
    private var keyboardListener: KeyboardAppearListener?
    
    private func checkActionButton() {
        guard
            !(passwordTextField.text?.isEmpty ?? true),
            !(confirmPasswordTextField.text?.isEmpty ?? true)
        else {
            actionBtn?.isEnabled = false
            
            return
        }
        
        actionBtn?.isEnabled = true
    }
    
    private func updateSecureToggle(button: UIButton?, textFieldSecured: Bool) {
        let bundle = Bundle(for: ELLoginContoller.self)
        let image = UIImage(named: textFieldSecured ? "eye-slash" : "eye", in: bundle, compatibleWith: nil)
        
        button?.setImage(image, for: .normal)
    }
}

// MARK: - Actions
extension ELNewPasswordController {
    private func bulletListMessage() -> String {
        let bulletList = [
            "invalidPasswordBulletPoints".localized,
        "invalidPasswordBulletPointsTwo".localized,
        "invalidPasswordBulletPointsThree".localized,
        "invalidPasswordBulletPointsFour".localized ]
        
        let bulletPoint = "\u{2022}"
        let formattedList = bulletList.map { "\(bulletPoint) \($0)" }.joined(separator: "\n")

        return formattedList
    }
    
    @IBAction private func actionBtnDidTap(_ sender: AnyObject?) {
        
        guard let password = passwordTextField.text, let newPassword = confirmPasswordTextField?.text, !newPassword.isEmpty else {
            onPasswordError?(BaseError.message("Error! Please enter a new password."))
            return
        }
        
        guard password.isValidPassword(),
              newPassword.isValidPassword() else {
            onPasswordError?(BaseError.message(bulletListMessage()))
            return
        }

        guard password == newPassword else {
            onPasswordError?(BaseError.message("passwordsNotMatch".localized))
            return
        }

        onTapSend?(password)
    }
    
    @IBAction private func textDidChange(_ sender: AnyObject?) {
        checkActionButton()
    }
    
    @IBAction private func passwordSecureToggleButtonTapped(_ sender: UIButton?) {
        passwordTextField.isSecureTextEntry.toggle()
        
        updateSecureToggle(button: sender, textFieldSecured: passwordTextField.isSecureTextEntry)
    }
    
    @IBAction private func confirmPasswordSecureToggleButtonTapped(_ sender: UIButton?) {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        
        updateSecureToggle(button: sender, textFieldSecured: confirmPasswordTextField.isSecureTextEntry)
    }
}

// MARK: - UITextFieldDelegate
extension ELNewPasswordController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkActionButton()
        
        return true
    }
}

// MARK: - Localization
private enum Localization: String {
    case newPasswordTitle
    case newPasswordSubtitle
    case newPassword
    case retypePassword
    case save
}
