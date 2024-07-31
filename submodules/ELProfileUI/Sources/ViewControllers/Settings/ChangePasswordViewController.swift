//
//  ChangePasswordViewController.swift
//  _idx_ELProfileUI_38A39E7F_ios_min11.0
//
//

import UIKit
import ELBase
import ElloAppCore
import ELCommonUI

public class ChangePasswordViewController: BaseViewController {
    
    public typealias Result = (password: String, newPassword: String)
    
    // MARK: - Public
    
    var onTapChangePasswordTo: EventClosure<(Result, EventClosure<Bool>)>?
    var onPasswordError: ErrorCallback?
    
    // MARK: - Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        checkActionBtn()
        
        currentPasswordTF?.onTextChange = { [weak self] _, _ in
            self?.checkActionBtn()
        }
        
        newPasswordTF?.onTextChange = { [weak self] _, _ in
            self?.checkActionBtn()
        }
        
        newPasswordConfirmTF?.onTextChange = { [weak self] _, _ in
            self?.checkActionBtn()
        }
        
        currentPasswordTF?.onReturn = { [weak self] in
            self?.newPasswordTF?.textField.becomeFirstResponder()
        }
        
        newPasswordTF?.onReturn = { [weak self] in
            self?.newPasswordConfirmTF?.textField.resignFirstResponder()
        }
        currentPasswordTF?.isSecure = true
        newPasswordTF?.isSecure = true
        newPasswordConfirmTF?.isSecure = true
        
    }
    
    public override func localize() {
        titleL?.text = Localization.changePassword.localized(bundle)
        changeBtn?.setTitle(Localization.change.localized(bundle), for: .normal)
        currentPasswordTF?.setPlaceholder(Localization.currentPassword.localized(bundle), isRequired: true)
        newPasswordTF?.setPlaceholder(Localization.newPassword.localized(bundle), isRequired: true)
        newPasswordConfirmTF?.setPlaceholder(Localization.confirmNewPassword.localized(bundle), isRequired: true)
    }
    
    public override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var titleL: UILabel?
    
    @IBOutlet private weak var currentPasswordTF: ValidationTextField!
    @IBOutlet private weak var currentAccessoryBtn: UIButton?
    
    @IBOutlet private weak var newPasswordTF: ValidationTextField!
    @IBOutlet private weak var newPasswordAccessoryBtn: UIButton?
    
    @IBOutlet private weak var newPasswordConfirmTF: ValidationTextField!
    @IBOutlet private weak var newPasswordConfirmAccessoryBtn: UIButton?
    
    @IBOutlet private weak var changeBtn: UIButton?
    
    private let bundle: Bundle = Bundle(for: ChangeEmailViewController.self)
    private let eyeImg = UIImage(named: "eye", in: Bundle(for: ChangeEmailViewController.self), compatibleWith: nil)
    private let eyeSlashImg = UIImage(named: "eye-slash", in: Bundle(for: ChangeEmailViewController.self), compatibleWith: nil)
        
    private func checkActionBtn() {
        let noPassValue = currentPasswordTF?.text?.isEmpty ?? true
        
        changeBtn?.isEnabled = noPassValue ? false : true
        changeBtn?.backgroundColor = noPassValue ? UIColor(hex: 0xcfcfd2) : UIColor(hex: 0x0a49a5)
    }
}

// MARK: - Actions

extension ChangePasswordViewController {
    
    @IBAction private func currentAccessoryBtnDidTap(_ sender: AnyObject?) {
        currentPasswordTF?.isSecure.toggle()
        let img = currentPasswordTF?.isSecure ?? false ? eyeSlashImg : eyeImg
        currentAccessoryBtn?.setImage(img, for: .normal)
    }
    
    @IBAction private func newPasswordAccessoryBtnDidTap(_ sender: AnyObject?) {
        newPasswordTF?.isSecure.toggle()
        let img = newPasswordTF?.isSecure ?? false ? eyeSlashImg : eyeImg
        newPasswordAccessoryBtn?.setImage(img, for: .normal)
    }
    
    @IBAction private func newPasswordConfirmAccessoryBtnDidTap(_ sender: AnyObject?) {
        newPasswordConfirmTF?.isSecure.toggle()
        let img = newPasswordConfirmTF?.isSecure ?? false ? eyeSlashImg : eyeImg
        newPasswordConfirmAccessoryBtn?.setImage(img, for: .normal)
    }
    
    @IBAction private func changeBtnDidTap(_ sender: AnyObject?) {
        
        guard let currentPassword = currentPasswordTF.text, let newPassword = newPasswordTF?.text, let newPasswordConfirm = newPasswordConfirmTF?.text, !newPassword.isEmpty else {
            if newPasswordTF?.text?.isEmpty ?? true{
                newPasswordTF?.errorDescription = "Error! Please enter a new password."
            }
            return
        }
        
        guard currentPassword.isValidPassword(),
              newPassword.isValidPassword(),
              newPasswordConfirm.isValidPassword() else {
            onPasswordError?(BaseError.message(bulletListMessage()))
            return
        }

        guard newPassword == newPasswordConfirm else {
            currentPasswordTF.errorDescription = "passwordsNotMatch".localized
            return
        }
        
        onTapChangePasswordTo?(((currentPasswordTF?.text ?? "", newPassword), { [weak self] isValid in
            if !isValid {
                self?.currentPasswordTF.errorDescription = "passwordsInvalid".localized
            }
        }))
    }
    
    func bulletListMessage() -> String {
        let bulletList = [
            "invalidPasswordBulletPoints".localized,
        "invalidPasswordBulletPointsTwo".localized,
        "invalidPasswordBulletPointsThree".localized,
        "invalidPasswordBulletPointsFour".localized ]
        
        let bulletPoint = "\u{2022}"
        let formattedList = bulletList.map { "\(bulletPoint) \($0)" }.joined(separator: "\n")

        return formattedList
    }
}

private enum Localization: String {
    case changePassword
    case currentPassword
    case newPassword
    case confirmNewPassword
    case change
}
