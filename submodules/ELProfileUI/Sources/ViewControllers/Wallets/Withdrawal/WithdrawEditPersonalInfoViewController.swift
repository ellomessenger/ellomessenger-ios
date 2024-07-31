//
//  WithdrawEditPersonalInfoViewController.swift
//  ElloAppApi
//
//  Created by Oleksii Zabrodin on 20.03.2024.
//

import UIKit
import ELBase
import ELCommonUI
import SwiftSignalKit
import ElloAppApi

enum WithdrawEditMode {
    case edit
    case add
}

class WithdrawEditPersonalInfoViewController: BaseViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var personalInfoLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var streetTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var postalcodeTextField: UITextField!
    @IBOutlet var nextButton: UIButton!
    
    public var onNextTap: EventClosure<BankWithdrawsItemWrapper>?
    public var walletItem: Api.wallet.WalletItem?
    public var bankWithdrawsItemWrapper: BankWithdrawsItemWrapper?
    public var mode: WithdrawEditMode = .add
    
    override func storyboardName() -> String {
        return "Wallet"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showBankWithdrawsItem()
        checkNextButton()
    }
    
    @IBAction func onNextTap(_ sender: Any) {
        if let bankWithdrawsItemWrapper {
            onNextTap?(bankWithdrawsItemWrapper)
        }
    }
    
    private func checkNextButton() {
        if !(firstNameTextField?.text?.isEmpty ?? true),
           !(lastNameTextField?.text?.isEmpty ?? true),
           !(phoneNameTextField?.text?.isEmpty ?? true),
           !(emailTextField?.text?.isEmpty ?? true),
           !(streetTextField?.text?.isEmpty ?? true),
           !(cityTextField?.text?.isEmpty ?? true),
           !(stateTextField?.text?.isEmpty ?? true),
           !(postalcodeTextField?.text?.isEmpty ?? true) {
                nextButton?.isEnabled = true
        }
        else {
                nextButton?.isEnabled = false
        }
    }
    
    private func showBankWithdrawsItem() {
        guard let bankWithdrawsItemWrapper else { return }
        firstNameTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.firstName
        lastNameTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.lastName
        phoneNameTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.phoneNumber
        emailTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.email
        
        streetTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.street
        cityTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.city
        stateTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.state
        postalcodeTextField.text = bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.postalCode
    }
}

extension WithdrawEditPersonalInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.borderGrey?.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        checkNextButton()
        return false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .bgGray
        textField.layer.borderWidth = 0
        
        checkNextButton()
        guard let bankWithdrawsItemWrapper else { return }
        if textField == firstNameTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo = PersonInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.firstName = firstNameTextField.text
        }
        else if textField == lastNameTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo = PersonInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.lastName = lastNameTextField.text
        }
        else if textField == phoneNameTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo = PersonInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.phoneNumber = phoneNameTextField.text
        }
        else if textField == emailTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo = PersonInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.personInfo?.email = emailTextField.text
        }
        else if textField == streetTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo = AddressInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.street = streetTextField.text
        }
        else if textField == cityTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo = AddressInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.city = cityTextField.text
        }
        else if textField == stateTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo = AddressInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.state = stateTextField.text
        }
        else if textField == postalcodeTextField {
            if nil == bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo { bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo = AddressInfoItem() }
            bankWithdrawsItemWrapper.bankWithdrawsItem.addressInfo?.postalCode = postalcodeTextField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let fields = [firstNameTextField, lastNameTextField, phoneNameTextField, emailTextField, 
                      streetTextField, cityTextField, stateTextField, postalcodeTextField]
        
        if let currentTextFieldIndex = fields.firstIndex(of: textField) {
            let nextIfieldIndex = currentTextFieldIndex + 1
            if nextIfieldIndex < fields.count {
                fields[nextIfieldIndex]?.becomeFirstResponder()
            }
            else {
                checkNextButton()
                if let bankWithdrawsItemWrapper, nextButton.isEnabled {
                    onNextTap?(bankWithdrawsItemWrapper)
                }
            }
        }
         
        return true
    }
}
