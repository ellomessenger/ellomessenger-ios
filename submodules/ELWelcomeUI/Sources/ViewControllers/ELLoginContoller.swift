//
//  ELLoginContoller.swift
//  _idx_ELLoginUI_7054C6BE_ios_min11.0
//
//

import Foundation
import UIKit
import ELBase


class ELLoginContoller: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var authTypeSegmentControl: UISegmentedControl? {
        didSet {
            let font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            authTypeSegmentControl?.setTitleTextAttributes([.font: font], for: .normal)
        }
    }
    @IBOutlet var mainStackView: UIStackView!
    
    @IBOutlet private weak var loginStack: UIStackView?
    
    @IBOutlet var loginView: UIView!
    
    @IBOutlet private weak var loginTF: UITextField?
    @IBOutlet var passwordView: UIView!
    @IBOutlet private weak var passwordTF: UITextField?
    @IBOutlet private weak var passwordToggleBtn: UIButton?
    @IBOutlet private weak var loginBtn: ELButton?
    @IBOutlet private weak var supportBtn: UIButton?
    @IBOutlet private weak var loginTypesDescriptionContainer: UIStackView?
    
    @IBOutlet private weak var registrationStack: UIStackView?
    @IBOutlet private var accountType: UIButton!
    @IBOutlet var personalTextLabel: UILabel!
    @IBOutlet var businessTextLabel: UILabel!
    @IBOutlet var backButton: UIView!
    
    // MARK: - Public
    
    /// Callback on tap login in sign in screen
    ///
    /// - Parameters:
    ///   - userName: username to login
    ///   - password: password to login
    ///   - completionHandler:Closure with **true** if success login, **false** if error
    ///
    var onTapLogin: ((_ userName: String, _ password: String, _ completionHandler: EventClosure<Bool>?) -> Void)?
    var onTapForgotPassword: (()->())?
    var onTapRegisterType: ((ProfileType)->())?
    var onTapLoginTypesDescription: (()->())?
    
    func reset() {
        authTypeSegmentControl?.selectedSegmentIndex = 0
        updateAuthTypeView()
    }
    
    // MARK: - Lifecycle
    override func localize() {
        personalTextLabel.text = "personalAccount".localized
        businessTextLabel.text = "businessAccount".localized
        accountType.setTitle("accountType".localized, for: .normal)
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.isHidden = onTapBack == nil
        setupUI()
    }

    override func storyboardName() -> String {
        return "WelcomeUI"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Additional Methods
    private func setupUI() {
        loginBtn?.isEnabled = false
        loginBtn?.apply(style: .blue)
        checkLoginBtns()
        updateAuthTypeView()
    }
    
    private func updateAuthTypeView() {
        switch authTypeSegmentControl?.selectedSegmentIndex {
        case 1:
            loginStack?.isHidden = true
            registrationStack?.isHidden = false
            supportBtn?.isHidden = true
            loginTypesDescriptionContainer?.isHidden = false
        default:
            loginStack?.isHidden = false
            registrationStack?.isHidden = true
            supportBtn?.isHidden = false
            loginTypesDescriptionContainer?.isHidden = true
        }
    }
    
    private func checkLoginBtns() {
        guard 
            !(loginTF?.text?.isEmpty ?? true),
            !(passwordTF?.text?.isEmpty ?? true) 
        else {
            loginBtn?.isEnabled = false
            return
        }
        loginBtn?.isEnabled = true
    }
}

// MARK: - Actions

extension ELLoginContoller {
    
    @IBAction private func loginTextFieldsDidChange(_ sender: AnyObject?) {
        checkLoginBtns()
    }
    
    @IBAction private func selectAuthTypeDidTap(_ sender: UISegmentedControl?) {
        loginTF?.resignFirstResponder()
        passwordTF?.resignFirstResponder()
        updateAuthTypeView()
    }
    
    @IBAction private func secureToggleDidTap(_ sender: AnyObject?) {
        passwordTF?.isSecureTextEntry.toggle()
        
        let isSecure = passwordTF?.isSecureTextEntry ?? false
        let bundle = Bundle(for: ELLoginContoller.self)
        let image = UIImage(named: isSecure ? "eye-slash" : "eye", in: bundle, compatibleWith: nil)

        passwordToggleBtn?.setImage( image, for: .normal)
    }
    
    @IBAction private func loginBtnDidTap(_ sender: AnyObject?) {
        guard
            let userName = loginTF?.text,
            let password = passwordTF?.text
        else {
            return
        }
        
        loginBtn?.isUserInteractionEnabled = false
        onTapLogin?(userName, password) { [weak self] isSuccess in
            self?.loginBtn?.isUserInteractionEnabled = true
        }
    }
    
    @IBAction private func forgotPassBtnDidTap(_ sender: AnyObject?) {
        onTapForgotPassword?()
    }
    
    @IBAction private func onRegisterTypeDidTap(_ sender: AnyObject?) {
        switch sender?.tag {
            case 0: onTapRegisterType?(.personal)
            default: onTapRegisterType?(.business)
        }
    }
    
    @IBAction private func onProfileTypeDescriptionTap(_ sender: AnyObject?) {
        onTapLoginTypesDescription?()
    }
    
    @IBAction private func onSupportTap(_ sender: AnyObject?) {
        guard let url = URL(string: "https://ellomessenger.com/support") else { return }
        UIApplication.shared.open(url)
    }
}

extension ELLoginContoller {
    
    public enum ProfileType {
        case personal
        case business
    }
}

extension ELLoginContoller: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
            case loginTF:
               self.loginTF?.backgroundColor = UIColor(hexString: "FFFFFF")
               self.loginView.backgroundColor = UIColor.white
               self.loginView.borderColor = UIColor(hexString: "#0A49A5")
               self.loginView.borderWidth = 1.0
        default:
            self.passwordTF?.backgroundColor = UIColor(hexString: "FFFFFF")
            self.passwordView.backgroundColor = UIColor.white
            self.passwordView.borderColor = UIColor(hexString: "#0A49A5")
            self.passwordView.borderWidth = 1.0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        if textFieldText.isEmpty {
            switch textField {
                case loginTF:
                   self.loginTF?.backgroundColor = UIColor(hexString: "#EEEEEF")
                   self.loginView.backgroundColor = UIColor(hexString: "#EEEEEF")
                   self.loginView.borderColor = UIColor.clear
                   self.loginView.borderWidth = 0
                default:
                   self.passwordTF?.backgroundColor = UIColor(hexString: "#EEEEEF")
                   self.passwordView.backgroundColor = UIColor(hexString: "#EEEEEF")
                   self.passwordView.borderColor = UIColor.clear
                   self.passwordView.borderWidth = 0
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case loginTF:
                passwordTF?.becomeFirstResponder()
            default:
                textField.resignFirstResponder()
        }
        return true
    }
}
