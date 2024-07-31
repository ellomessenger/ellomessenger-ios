//
//  WithdrawalBankInfoViewController.swift
//  _idx_ElloAppApi_E33B064A_ios_min14.0
//

import UIKit
import ElloAppApi
import ELBase
import ELCommonUI

class WithdrawalBankInfoViewController: BaseViewController {
    public var onTapOption: EventClosure<BankInfoObject>?
    public var onTapBackOption: VoidClosure?
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var countryInput: UITextField?
    @IBOutlet private weak var nameInput: UITextField?
    @IBOutlet private weak var streetInput: UITextField?
    @IBOutlet private weak var swiftInput: UITextField?
    @IBOutlet private weak var addressInput: UITextField?
    @IBOutlet private weak var cityInput: UITextField?
    
    @IBOutlet private weak var zipCodeInput: UITextField?
    @IBOutlet private weak var recipientNumberInput: UITextField?
    @IBOutlet private weak var verifyRecipientNumberInput: UITextField?
    @IBOutlet private weak var checkedImageView: UIImageView?
    @IBOutlet private weak var amountLabel: UILabel?
    
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var backButton: UIButton?
    
    private var isCheckBoxSelected = false
    var amount = 0.0
    var userAddressObject: UserAddressObject?
    var isUSA = false
    var isBusiness = false
    var isChosenCountryUS = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalisation()
        amountLabel?.text = String(amount) + " " + (userAddressObject?.currency ?? "USD")
        if isUSA || isChosenCountryUS {
            countryInput?.isHidden = true
            swiftInput?.isHidden = true
            zipCodeInput?.isHidden = true
            zipCodeInput?.placeholder = "Withdrawal.BankPersonalZIPCode".localized
        } else {
            if !isBusiness {
                countryInput?.isHidden = false
                swiftInput?.isHidden = false
                zipCodeInput?.isHidden = false
                zipCodeInput?.placeholder = "Withdrawal.BankPersonalPostalCode".localized
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton?.setTitleColor(.buttonDarkGrey, for: .disabled)
        checkNextButton()
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    private func setupLocalisation() {
        titleL?.text = "transferOut".localized
        nextButton?.titleLabel?.text = "transferOut".localized
        backButton?.titleLabel?.text = "back".localized
        
        nameInput?.placeholder = "Withdrawal.BankName".localized
        streetInput?.placeholder = "Withdrawal.BankPersonalStreet".localized
        swiftInput?.placeholder = "Withdrawal.BankSwift".localized
        addressInput?.placeholder = "Withdrawal.BankAddress".localized
        cityInput?.placeholder = "Withdrawal.BankPersonalCity".localized
        
        recipientNumberInput?.placeholder = "Withdrawal.BankRecipientAccount".localized
        verifyRecipientNumberInput?.placeholder = (isUSA || isChosenCountryUS) ? "Withdrawal.BankReEntertAccount".localized : "Withdrawal.BankMessage".localized
    }
    
    private func checkNextButton() {
        if isUSA || isChosenCountryUS {
            if nameInput?.text?.isEmpty ?? false,
               streetInput?.text?.isEmpty ?? false,
               cityInput?.text?.isEmpty ?? false,
               addressInput?.text?.isEmpty ?? false,
               recipientNumberInput?.text?.isEmpty ?? false,
               verifyRecipientNumberInput?.text?.isEmpty ?? false {
                
                nextButton?.isEnabled = false
                nextButton?.setTitleColor(.textGray, for: .normal)
                nextButton?.backgroundColor = UIColor(hex: 0xcfcfd2)
                return
            }
        } else {
            if countryInput?.text?.isEmpty ?? false,
               swiftInput?.text?.isEmpty ?? false,
               nameInput?.text?.isEmpty ?? false,
               streetInput?.text?.isEmpty ?? false,
               cityInput?.text?.isEmpty ?? false,
               zipCodeInput?.text?.isEmpty ?? false,
               recipientNumberInput?.text?.isEmpty ?? false,
               verifyRecipientNumberInput?.text?.isEmpty ?? false {
                
                nextButton?.isEnabled = false
                nextButton?.setTitleColor(.textGray, for: .disabled)
                nextButton?.backgroundColor = .buttonDarkGrey
                return
            }
        }
        nextButton?.isEnabled = true
        nextButton?.setTitleColor(.white, for: .normal)
        nextButton?.backgroundColor = .buttonBlue
    }
    
    private func setupData() -> BankInfoObject? {
        let bankName = nameInput?.text ?? ""
        let bankCountry = countryInput?.text ?? ""
        let swift = swiftInput?.text ?? ""
        let street = streetInput?.text ?? ""
        let city = cityInput?.text ?? ""
        let address = addressInput?.text ?? ""
        let recipientNumber = recipientNumberInput?.text ?? ""
        let zipCode = zipCodeInput?.text ?? ""
        let message = verifyRecipientNumberInput?.text ?? ""
        
        return BankInfoObject(bankCountry: bankCountry, bankName: bankName, swift: swift, street: street, city: city, address: address, zipCode: zipCode, recipientNumber: recipientNumber, messageRecipientBank: message)
    }
    
    // MARK: - IBActions
    @IBAction private func tapNextButton() {
        if let object = setupData() {
            onTapOption?(object)
        }
    }
    
    @IBAction private func saveCard() {
        isCheckBoxSelected.toggle()
        checkedImageView?.image = isCheckBoxSelected ? UIImage(named: "checkbox-checked", in: Bundle(for: Self.self), compatibleWith: nil) : UIImage(named: "checkbox-empty", in: Bundle(for: Self.self), compatibleWith: nil)
        
    }
}

// MARK: - UITextFieldDelegate
extension WithdrawalBankInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.borderGrey?.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .bgGray
        textField.layer.borderWidth = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextTextField = view.viewWithTag(nextTag) as? UITextField {
            nextTextField.isEnabled = true
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        checkNextButton()
        return true
    }
}
