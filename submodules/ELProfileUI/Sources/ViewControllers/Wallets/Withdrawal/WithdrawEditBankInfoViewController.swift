//
//  WithdrawEditBankInfoViewController.swift
//  ElloAppApi
//
//  Created by Ello on 21.03.2024.
//

import UIKit
import ELBase
import ELCommonUI
import SwiftSignalKit
import ElloAppApi

class WithdrawEditBankInfoViewController: BaseViewController {

    @IBOutlet var bankCountryLabel: UILabel!
    @IBOutlet var recipientTypeLabel: UILabel!
    @IBOutlet var businessIdentificationNumberTextField: UITextField!
    @IBOutlet var recipientDescriptionLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var currencyTextField: UITextField!
    @IBOutlet var currencyDescriptionLabel: UILabel!
    @IBOutlet var bankInfoLabel: UILabel!
    @IBOutlet var bankNameTextField: UITextField!
    @IBOutlet var streetTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var routingNumberTextField: UITextField!
    @IBOutlet var recipientAccountNumberTextField: UITextField!
    @IBOutlet var swiftCodeTextField: UITextField!
    @IBOutlet var ibanNumberTextField: UITextField!
    @IBOutlet var ibanDescriptionLabel: UILabel!
    @IBOutlet var verifyRecipientAccountNumberTextField: UITextField!
    @IBOutlet var reenterIbanNumberTextField: UITextField!
    @IBOutlet var saveCheckView: UIStackView!
    @IBOutlet var saveCheckButton: UIButton!
    @IBOutlet var saveCheckImageView: UIImageView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var amountView: UIStackView!
    @IBOutlet var withdrawButton: UIButton!
    
    @IBOutlet private weak var countryContainer: UIView?
    @IBOutlet private weak var countryL: UILabel?
    @IBOutlet private weak var countryTable: UITableView?
    @IBOutlet private weak var countryTableContainer: UIView?
    
    @IBOutlet var recipientContainer: UIView!
    @IBOutlet var recipientL: UILabel!
    @IBOutlet var recipientSheetView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    public var onWithdraw: EventClosure<BankWithdrawsItem>?
    public var walletItem: Api.wallet.WalletItem?
    public var amount: Double?
    public var mode: WithdrawEditMode = .add
    
    public var bankWithdrawsItemWrapper: BankWithdrawsItemWrapper?
    
    override func storyboardName() -> String {
        return "Wallet"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCountries()
        setupShadow(countryTableContainer)
        setupShadow(recipientSheetView)
        refresh()
    }
    
    @IBAction private func countriesBtnDidTap(_ sender: AnyObject?) {
        view.endEditing(true)
        countryTableContainer?.isHidden.toggle()
        recipientSheetView?.isHidden = true
    }

    @IBAction func onRecipientTypeTap(_ sender: Any) {
        view.endEditing(true)
        recipientSheetView?.isHidden.toggle()
        countryTableContainer?.isHidden = true
    }
    
    @IBAction func onIndividualTap(_ sender: Any) {
        recipientL.text = BankWithdrawsRecipientType.individual.rawValue.capitalized
        bankWithdrawsItemWrapper?.bankWithdrawsItem.recipientType = BankWithdrawsRecipientType.individual.rawValue
        recipientSheetView?.isHidden = true
        hideViews()
        showViews()
    }
    
    @IBAction func onBusinessTap(_ sender: Any) {
        recipientL.text = BankWithdrawsRecipientType.business.rawValue.capitalized
        bankWithdrawsItemWrapper?.bankWithdrawsItem.recipientType = BankWithdrawsRecipientType.business.rawValue
        recipientSheetView?.isHidden = true
        hideViews()
        showViews()
    }
    
    @IBAction func onWithdrawTap(_ sender: Any) {
        guard let bankWithdrawsItem = bankWithdrawsItemWrapper?.bankWithdrawsItem else { return }
        onWithdraw?(bankWithdrawsItem)
    }
    
    @IBAction func onSaveCheckButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        bankWithdrawsItemWrapper?.bankWithdrawsItem.isTemplate = sender.isSelected
    }
    
    private func hideViews() {
        [bankCountryLabel,
         countryContainer!,
         recipientTypeLabel,
         recipientContainer,
         businessIdentificationNumberTextField,
         recipientDescriptionLabel,
         currencyLabel,
         currencyTextField,
         currencyDescriptionLabel,
         bankInfoLabel,
         bankNameTextField,
         streetTextField,
         cityTextField,
         stateTextField,
         routingNumberTextField,
         recipientAccountNumberTextField,
         swiftCodeTextField,
         ibanNumberTextField,
         ibanDescriptionLabel,
         verifyRecipientAccountNumberTextField,
         reenterIbanNumberTextField].forEach({$0?.superview?.isHidden = true})
    }
    
    private var views: [UIView] {
        if bankWithdrawsItemWrapper?.bankWithdrawsItem.isUSA ?? false {
            return [ bankCountryLabel,
                     countryContainer!,
                     bankInfoLabel,
                     bankNameTextField,
                     streetTextField,
                     cityTextField,
                     stateTextField,
                     routingNumberTextField,
                     recipientAccountNumberTextField,
                     ibanDescriptionLabel,
                     verifyRecipientAccountNumberTextField]
        }
        else {
            if  bankWithdrawsItemWrapper?.bankWithdrawsItem.isBusiness ?? false {
                return [ bankCountryLabel,
                         countryContainer!,
                         recipientTypeLabel,
                         recipientContainer,
                         businessIdentificationNumberTextField,
                         recipientDescriptionLabel,
                         currencyLabel,
                         currencyTextField,
                         currencyDescriptionLabel,
                         bankInfoLabel,
                         bankNameTextField,
                         swiftCodeTextField,
                         ibanNumberTextField,
                         ibanDescriptionLabel,
                         reenterIbanNumberTextField]
            }
            else {
                return [ bankCountryLabel,
                         countryContainer!,
                         recipientTypeLabel,
                         recipientContainer,
                         currencyLabel,
                         currencyTextField,
                         currencyDescriptionLabel,
                         bankInfoLabel,
                         bankNameTextField,
                         streetTextField,
                         swiftCodeTextField,
                         ibanNumberTextField,
                         ibanDescriptionLabel,
                         reenterIbanNumberTextField]
            }
        }
    }
    
    private func showViews() {
        views.forEach({$0.superview?.isHidden = false})
    }
    
    private func refresh() {
        hideViews()
        showViews()
        
        countryL?.text = country?.name.capitalized ?? ""
        recipientL.text = (bankWithdrawsItemWrapper?.bankWithdrawsItem.recipientType ?? BankWithdrawsRecipientType.individual.rawValue).capitalized
        businessIdentificationNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.businessIdNumber
        currencyTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.currency
        bankNameTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.name
        streetTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.street
        cityTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.city
        stateTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.state
        routingNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.routingNumber
        swiftCodeTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.swift
        recipientAccountNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber
        ibanNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber
        verifyRecipientAccountNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber
        reenterIbanNumberTextField.text = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber

        amountLabel.text = (amount ?? 0.0).stringFinanceFormat
        saveCheckButton?.isSelected = bankWithdrawsItemWrapper?.bankWithdrawsItem.isTemplate ?? false
        
        checkNextButton()
    }
    
// MARK: - Countries
    private var countries: [Country] = [] {
        didSet {
            countryTable?.reloadData()
            if let selectedCountry = bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.country,
               let index = countries.firstIndex(where: {$0.code.lowercased() == selectedCountry.lowercased()})
            {
                let indexPath = IndexPath(row: index, section: 0)
                countryTable?.scrollToRow(at: indexPath, at: .middle, animated: true)
                country = countries[index]
            }
        }
    }
    
    private var country: Country? {
        didSet {
            countryL?.text = country?.name.capitalized
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.country = country?.code.uppercased()
        }
    }
    
    private func loadCountries() {
        ELProfileController.reloadCountries { [weak self] countries in
            self?.countries = countries
        }
    }
    
    private func setupShadow(_ view: UIView?) {
        view?.layer.cornerRadius = 13.0
        view?.layer.shadowColor = UIColor.gray.cgColor
        view?.layer.shadowOpacity = 0.5
        view?.layer.shadowRadius = 10.0
        view?.layer.shadowOffset = .zero
        view?.layer.shadowPath = UIBezierPath(rect: view?.bounds ?? .zero).cgPath
        view?.layer.shouldRasterize = false
    }
    
    private func checkNextButton() {
        let isAllFieldsFilled = (views.first(where: {return ($0 as? UITextField)?.text?.isEmpty ?? false})) == nil
        let isEnabled = isAllFieldsFilled &&
        ((reenterIbanNumberTextField.text == ibanNumberTextField.text) ||
         (verifyRecipientAccountNumberTextField.text == recipientAccountNumberTextField.text))
        withdrawButton?.isEnabled = isEnabled
        withdrawButton?.backgroundColor = isEnabled ? UIColor.buttonBlue : UIColor.buttonDarkGrey
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WithdrawEditBankInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "country") as? ELOptionCell {
            let country = countries[indexPath.row]
            cell.title = country.name
            cell.iconUrl = country.flag
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        country = countries[indexPath.row]
        countryTableContainer?.isHidden = true
        refresh()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
}

// MARK: - UITextFieldDelegate
extension WithdrawEditBankInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.borderGrey?.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .bgGray
        textField.layer.borderWidth = 0
        
        checkNextButton()
        if textField == bankNameTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.name = bankNameTextField.text
        }
        else if textField == currencyTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.currency = currencyTextField.text
        }
        else if textField == streetTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.street = streetTextField.text
        }
        else if textField == cityTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.city = cityTextField.text
        }
        else if textField == stateTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.state = stateTextField.text
        }
        else if textField == routingNumberTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.routingNumber = routingNumberTextField.text
        }
        else if textField == swiftCodeTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.swift = swiftCodeTextField.text
        }
        else if textField == businessIdentificationNumberTextField {
            bankWithdrawsItemWrapper?.bankWithdrawsItem.businessIdNumber = businessIdentificationNumberTextField.text
        }
        else if textField == recipientAccountNumberTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber = recipientAccountNumberTextField.text
            checkNextButton()
        }
        else if textField == ibanNumberTextField {
            if nil == bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo { bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo = BankInfoItem() }
            bankWithdrawsItemWrapper?.bankWithdrawsItem.bankInfo?.recipientAccountNumber = ibanNumberTextField.text
            checkNextButton()
        }
        else if textField == verifyRecipientAccountNumberTextField {
            checkNextButton()
        }
        else if textField == reenterIbanNumberTextField {
            checkNextButton()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let fields = views.filter({$0 is UITextField})
        
        if let currentTextFieldIndex = fields.firstIndex(of: textField) {
            let nextFieldIndex = currentTextFieldIndex + 1
            if nextFieldIndex < fields.count {
                fields[safe: nextFieldIndex]?.becomeFirstResponder()
            }
            else {
                checkNextButton()
                if let bankWithdrawsItem = bankWithdrawsItemWrapper?.bankWithdrawsItem, withdrawButton.isEnabled {
                    onWithdraw?(bankWithdrawsItem)
                }
            }
        }
         
        return true
    }
}

extension WithdrawEditBankInfoViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            countryTableContainer?.isHidden = true
            recipientSheetView?.isHidden = true
        }
    }
}
