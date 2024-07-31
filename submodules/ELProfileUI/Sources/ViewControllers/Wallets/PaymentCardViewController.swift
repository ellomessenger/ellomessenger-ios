//
//  PaymentCardViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 19/2/23.
//

import Foundation

import UIKit
import ELBase
import ElloAppApi


class PaymentCardViewController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var navLabel: UILabel!
    @IBOutlet var cardInfoLabel: UILabel!
    @IBOutlet var cardHolderLabel: UILabel!
    @IBOutlet var cardNumberTextField: TextFieldPadding!
    @IBOutlet var monthYearTextField: TextFieldPadding!
    @IBOutlet var cvvTextField: TextFieldPadding!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var cardHolderTextField: TextFieldPadding!
    
    // MARK: - Properties
    public var onTapOption: EventClosure<Api.wallet.PaymentItem>?
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    var walletItem: Api.wallet.WalletItem?
    var topUpAmount: Double = 0
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.becomeFirstResponder()
        payButton.setTitle(String(format: "Pay $%0.2f", topUpAmount) , for: .normal)
        
        if #unavailable(iOS 16) {
            NSLayoutConstraint.activate([
                payButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16.0)
            ])
        }
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    override func localize() {
        navLabel.text = "Withdrawal.BankTransferTitle".localized
        cvvTextField.placeholder = "Wallets.CardCvv".localized
        cardInfoLabel.text = "Wallets.CardInfoTitle".localized
        cardHolderLabel.text = "Wallets.CardholderTitle".localized
        cardHolderTextField.placeholder = "Wallets.CardholderTitle".localized.capitalizeFirst()
    }
    
    // MARK: - IBActions
    @IBAction func payButtonTapped(_ sender: UIButton) {
        guard let walletItem else { return }
        guard let cardNumber = cardNumberTextField.text else { return }
        guard let csvString = cvvTextField.text, let csv = Int(csvString) else { return }
        let monthAndYear = monthYearTextField.text?.components(separatedBy: "/")
        guard let monthString = monthAndYear?.first, let yearString = monthAndYear?.last else { return }
        guard let month = Int(monthString), let year = Int(yearString) else { return }
        
        let cardHolder = cardHolderTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        let paymentItem = Api.wallet.PaymentItem(
            paymentSystem: TopUpMethodModel.bankCard.rawValue,
            assetId: 2,
            walletId: walletItem.id,
            currency: walletItem.assetSymbol,
            message: "",
            number: cardNumber,
            expMonth: month,
            expYear: year,
            csv: csv,
            amount: topUpAmount,
            holder: cardHolder.isEmpty ? nil : cardHolder
        )
        
        onTapOption?(paymentItem)
    }
    
    @IBAction func cardNumberTextFieldEditingChanged(_ sender: TextFieldPadding) {
        validate(textField: sender, maxLength: 19, partLength: 4, separator: " ")
        
        payButton.isEnabled = isValidCardData()
    }
    
    @IBAction func monthYearTextFieldEditingChanged(_ sender: TextFieldPadding) {
        validate(textField: sender, maxLength: 4, partLength: 2, separator: "/")
        
        payButton.isEnabled = isValidCardData()
    }
    
    @IBAction func cvvTextFieldEditingChanged(_ sender: TextFieldPadding) {
        validate(textField: sender, maxLength: 4)
        
        payButton.isEnabled = isValidCardData()
    }
    
    @IBAction func cardHolderTextFieldEditingChange(_ sender: Any) {
    }
    
    // MARK: - Actions
    
    func dateValidate(input: String) -> Bool {
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MM/yy"
           
           guard let date = dateFormatter.date(from: input) else {
               return false
           }
           
           let currentDate = Date()
           
           return date > currentDate
    }

    private func isValidCardData() -> Bool {
        guard let cardNumber = cardNumberTextField.text,
              let monthYear = monthYearTextField.text,
              let cvv = cvvTextField.text else {
            return false
        }
        
        let isCardNumberValid = (19...23).contains(cardNumber.count)
        let isMonthYearValid = dateValidate(input: monthYearTextField.text ?? "")
        
        return isCardNumberValid &&
        isMonthYearValid &&
        monthYear.count == 5 &&
        (cvv.count == 3 || cvv.count == 4)
    }
    
    private func validate(textField: TextFieldPadding, maxLength: Int, partLength: Int? = nil, separator: String? = nil) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSeparators = ""
        if let text = textField.text {
            cardNumberWithoutSeparators = removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSeparators.count > maxLength {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        if let partLength, let separator {
            let cardNumberWithSeparators = insertSeparator(
                separator,
                partLength: partLength,
                to: cardNumberWithoutSeparators,
                preserveCursorPosition: &targetCursorPosition
            )
            textField.text = cardNumberWithSeparators
        }
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    private func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    private func insertSeparator(_ separator: String, partLength: Int, to string: String, preserveCursorPosition cursorPosition: inout Int) -> String {
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.count {
            let needs4444Spacing = (i > 0 && (i % partLength) == 0)
            
            if needs4444Spacing {
                stringWithAddedSpaces.append(separator)
                
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
}

// MARK: - UITextFieldDelegate
extension PaymentCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        previousTextFieldContent = textField.text
        previousSelection = textField.selectedTextRange
        
        return true
    }
}
