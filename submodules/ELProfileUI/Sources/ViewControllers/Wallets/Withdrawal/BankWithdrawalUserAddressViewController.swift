//
//  WithdrawalBankUserAddressViewController.swift
//  _idx_ElloAppApi_E33B064A_ios_min14.0
//

import UIKit
import ELBase
import ELCommonUI
import SwiftSignalKit

class BankWithdrawalUserAddressViewController: BaseViewController {
    
    public var onTapOption: EventClosure<UserAddressObject>?
    
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var addressInput: UITextField?
    @IBOutlet private weak var streetInput: UITextField?
    @IBOutlet private weak var cityInput: UITextField?
    @IBOutlet private weak var stateInput: UITextField?
    @IBOutlet private weak var zipCodeInput: UITextField?
    @IBOutlet private weak var idNumberInput: UITextField?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var backButton: UIButton?
    @IBOutlet private weak var receipTypeContainer: UIView?
    @IBOutlet private weak var receipTypeLabel: UILabel?
    @IBOutlet private weak var receipTypeTableContainer: UIView?
    @IBOutlet private weak var receipTypeTable: UITableView?
    
    @IBOutlet private weak var currencyLabel: UILabel?
    @IBOutlet private weak var currencyContainer: UIView?
    @IBOutlet private weak var currencyContainerLabel: UILabel?
    @IBOutlet private weak var currencyTableContainer: UIView?
    @IBOutlet private weak var currencyTable: UITableView?
    private var currencyArray = ["USD", "ELLO"]
    private var receipTypeArray = ["Bussiness", "Individual"]
    private var userObject: UserAddressObject?
    private var currency = ""
    private var receipType = ""
    
    var isUSA = false
    var isBusiness = false
    var isChosenCountryUS = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUSA || isChosenCountryUS {
            currencyLabel?.isHidden = true
            currencyContainer?.isHidden = true
            receipTypeContainer?.isHidden = true
            idNumberInput?.isHidden = true
        } else {
            if isBusiness {
                currencyLabel?.isHidden = false
                currencyContainer?.isHidden = false
                receipTypeContainer?.isHidden = false
                idNumberInput?.isHidden = true
            } else {
                currencyLabel?.isHidden = true
                receipTypeContainer?.isHidden = false
                currencyContainer?.isHidden = true
                idNumberInput?.isHidden = false
            }
        }
        backButton?.backgroundColor = .buttonDarkGrey
        backButton?.isEnabled = true
        setupLocalisation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton?.setTitleColor(.textGray, for: .disabled)
        checkNextButton()
        setupShadow(currencyTableContainer)
        setupShadow(receipTypeTableContainer)
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    private func setupLocalisation() {
         titleL?.text = "transferOut".localized
         nextButton?.titleLabel?.text = "next".localized
         backButton?.titleLabel?.text = "back".localized

        addressInput?.placeholder = "Withdrawal.BankPersonalAddress".localized
        streetInput?.placeholder = "Withdrawal.BankPersonalStreet".localized
        cityInput?.placeholder = "Withdrawal.BankPersonalCity".localized
            
        stateInput?.placeholder = (isUSA || isChosenCountryUS) ? "Withdrawal.BankPersonalState".localized : "Withdrawal.BankPersonalRegion".localized
        zipCodeInput?.placeholder = (isUSA || isChosenCountryUS) ? "Withdrawal.BankPersonalZIPCode".localized : "Withdrawal.BankPersonalPostalCode".localized
        receipTypeLabel?.text = "Withdrawal.BankReceipType".localized
        currencyLabel?.text = "Withdrawal.Currency".localized
    }
    
    private func checkNextButton() {
        if addressInput?.text?.isEmpty ?? false,
        streetInput?.text?.isEmpty ?? false,
        cityInput?.text?.isEmpty ?? false,
        stateInput?.text?.isEmpty ?? false {
            nextButton?.isEnabled = false
            nextButton?.backgroundColor = .buttonDarkGrey
            return
        }
        
        nextButton?.isEnabled = true
        nextButton?.backgroundColor = .buttonBlue
        nextButton?.setTitleColor(.white, for: .normal)
    }
    
    private func setupData() -> UserAddressObject? {
        let address = addressInput?.text ?? ""
        let street = streetInput?.text ?? ""
        let city = cityInput?.text ?? ""
        let state = stateInput?.text ?? ""
        let zipCode = zipCodeInput?.text ?? ""
        let idNumber = idNumberInput?.text ?? ""
        
        userObject = UserAddressObject(address: address, street: street, city: city, state: state, zipCode: zipCode, receipientType: receipType, idNumber: idNumber)
        return userObject
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
    
    // MARK: - IBActions
    @IBAction private func tapNextButton() {
        if let object = setupData() {
            onTapOption?(object)
        }
    }
    
    @IBAction private func currenciesButtonDidTap(_ sender: AnyObject?) {
        currencyTableContainer?.isHidden.toggle()
        receipTypeTableContainer?.isHidden = true
        view.endEditing(true)
    }
    
    @IBAction private func receptButtonDidTap(_ sender: AnyObject?) {
        receipTypeTableContainer?.isHidden.toggle()
        currencyTableContainer?.isHidden = true
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension BankWithdrawalUserAddressViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.borderGrey?.cgColor
        textField.layer.borderWidth = 1.0
        receipTypeTableContainer?.isHidden = true
        currencyTableContainer?.isHidden = true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .bgGray
        textField.layer.borderWidth = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkNextButton()
        return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BankWithdrawalUserAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == currencyTable {
            return currencyArray.count
        }
        if tableView == receipTypeTable {
            return receipTypeArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "option") ?? UITableViewCell(style: .default, reuseIdentifier: "option")
        
        if tableView == currencyTable {
            let currency = currencyArray[indexPath.row]
            cell.textLabel?.text = currency
        }
        if tableView == receipTypeTable {
            let receip = receipTypeArray[indexPath.row]
            cell.textLabel?.text = receip
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == currencyTable {
            currency = currencyArray[indexPath.row]
            currencyContainerLabel?.text = currency
            currencyTableContainer?.isHidden = true
        } else {
            receipType = receipTypeArray[indexPath.row]
            receipTypeLabel?.text = receipType
            receipTypeTableContainer?.isHidden = true
        }
        checkNextButton()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
}
