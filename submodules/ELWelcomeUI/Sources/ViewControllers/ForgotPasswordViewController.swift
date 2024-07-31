//
//  ForgotPasswordViewController.swift
//  _idx_ElloAppApi_4F7BAED4_ios_min11.0
//
//

import UIKit
import ELBase

class ForgotPasswordViewController: BaseViewController {
    private enum TextFieldState {
        case normal
        case error
        
        var borderColor: UIColor? {
            switch self {
            case .normal:
                UIColor(named: "InputActive", in: Bundle(for: ForgotPasswordViewController.self), compatibleWith: nil)
            case .error:
                UIColor(named: "InputError", in: Bundle(for: ForgotPasswordViewController.self), compatibleWith: nil)
            }
        }
    }
    // MARK: - IBOutlets
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var descriptionL: UILabel?
    @IBOutlet private weak var inputTF: UITextField?
    @IBOutlet private weak var actionBtn: ELButton?
    @IBOutlet private weak var errorLabel: UILabel!
    
    private var keyboardListener: KeyboardAppearListener?
    private var textFieldState: TextFieldState = .normal {
        didSet {
            inputTF?.superview?.borderColor = textFieldState.borderColor
        }
    }
    
    // MARK: - Public
    var onTapSend: TwoEventsClosure<String, EventClosure<Result<Never, Error>>>?
    
    // MARK: - Lifecycle
    
    override func localize() {
        titleL?.text = Localization.resetPassword.localized(Bundle(for: Self.self))
        descriptionL?.text = Localization.resetPasswordDescription.localized(Bundle(for: Self.self))
        inputTF?.placeholder = Localization.emailAddress.localized(Bundle(for: Self.self))
        actionBtn?.setTitle(Localization.send.localized(Bundle(for: Self.self)), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.isHidden = true
        keyboardListener = KeyboardAppearListener(self)
        actionBtn?.apply(style: .blue)
        checkActionButton()
        inputTF?.becomeFirstResponder()
    }
    
    override func storyboardName() -> String {
        return "WelcomeUI"
    }
    
    // MARK: - Private
    private func checkActionButton() {
        if (inputTF?.text?.isEmpty ?? true)
            || !(inputTF?.text?.isValidEmail() ?? false) {
            actionBtn?.isEnabled = false
            return
        }
        
        actionBtn?.isEnabled = true
    }
}

// MARK: - Actions

extension ForgotPasswordViewController {
    
    @IBAction private func actionBtnDidTap(_ sender: AnyObject?) {
        onTapSend?(inputTF?.text ?? "") { [weak self] result in
            switch result {
            case .failure(_):
                self?.errorLabel.isHidden = false
                self?.actionBtn?.isEnabled = false
                self?.textFieldState = .error
            }
        }
    }
    
    @IBAction private func textDidChange(_ sender: AnyObject?) {
        errorLabel.isHidden = true
        textFieldState = .normal
        
        checkActionButton()
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkActionButton()
        return true
    }
}

// MARK: - Localization

private enum Localization: String {
    case resetPassword
    case resetPasswordDescription
    case emailAddress
    case send
}
