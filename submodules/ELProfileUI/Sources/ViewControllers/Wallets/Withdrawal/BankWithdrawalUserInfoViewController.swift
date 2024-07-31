//
//  WithdrawalBankPersonalInfoViewController.swift
//  _idx_AccountContext_9BC4C79F_ios_min14.0
//n

import UIKit
import ElloAppApi
import ELBase
import ELCommonUI
import SwiftSignalKit

class BankWithdrawalUserInfoViewController: BaseViewController {
    typealias CheckUsernameParams = (username: String, completion: EventClosure<Bool>)
    typealias CheckEmailParams = (email: String, completion: EventClosure<Bool>)
    public var onTapOption: EventClosure<UserInfoObject>?
    
    weak var delegate: ValidationTextFieldDelegate?
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var bankRoutingNumberLabel: UILabel?
    @IBOutlet private weak var bankRoutingNumberInput: ValidationTextField?
    @IBOutlet private weak var firstNameInput: ValidationTextField?
    @IBOutlet private weak var lastNameInput: ValidationTextField?
    @IBOutlet private weak var phoneInput: ValidationTextField?
    @IBOutlet private weak var emailInput: ValidationTextField?
    @IBOutlet private weak var countryContainer: UIView?
    @IBOutlet private weak var countryL: UILabel?
    @IBOutlet private weak var countryTableContainer: UIView?
    @IBOutlet private weak var countryTable: UITableView?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var bottomLC: NSLayoutConstraint?
    var isUSA = false
    var isBusiness = false
    var isChosenCountryUS = false
    private var bankRoutingNumber = ""
    private var firstName = ""
    private var lastName = ""
    private var phone = ""
    private var email = ""
    
    private var countries: [Country] = [] {
        didSet {
            countryTable?.reloadData()
        }
    }
    
    private var country: Country? {
        didSet {
            countryL?.text = country?.name
        }
    }
    
    private func loadCountries() {
        ELProfileController.reloadCountries { [weak self] countries in
            self?.countries = countries
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCountries()
        setupLocalisation()
        
        firstNameInput?.validator = NameValidator()
        firstNameInput?.maxLength = 20
        firstNameInput?.validationDelegate = self
        firstNameInput?.onTextChange = { [weak self] text, _ in
            self?.checkNextButton()
            self?.firstName = text ?? ""
        }
        lastNameInput?.validator = NameValidator()
        lastNameInput?.maxLength = 20
        lastNameInput?.validationDelegate = self
        lastNameInput?.onTextChange = { [weak self] text, _ in
            self?.checkNextButton()
            self?.lastName = text ?? ""
        }
        phoneInput?.textField.keyboardType = .phonePad
        phoneInput?.validationDelegate = self
        phoneInput?.onTextChange = { [weak self] text, _ in
            self?.checkNextButton()
            self?.phone = text ?? ""
        }
        emailInput?.validator = EmailValidator()
        emailInput?.validationDelegate = self
        emailInput?.validationDelegate = self
        emailInput?.textField.keyboardType = .emailAddress
        emailInput?.onTextChange = { [weak self] text, _ in
            self?.checkNextButton()
            self?.email = text ?? ""
        }
        bankRoutingNumberInput?.textField.keyboardType = .numberPad
        bankRoutingNumberInput?.onTextChange = { [weak self] text, _ in
            self?.checkNextButton()
            self?.bankRoutingNumber = text ?? ""
        }
        
        if isChosenCountryUS || isUSA {
            bankRoutingNumberLabel?.isHidden = false
            bankRoutingNumberInput?.isHidden = false
        } else {
            bankRoutingNumberLabel?.isHidden = true
            bankRoutingNumberInput?.isHidden = true
        }

        registerKeyboardNotifications(bottomConstraint: bottomLC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton?.backgroundColor = .buttonDarkGrey
        nextButton?.setTitleColor(.textGray, for: .disabled)
        checkNextButton()
        countryTable?.reloadData()
        setupShadow(countryTableContainer)
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    private func setupLocalisation() {
        titleL?.text = "transferOut".localized
        nextButton?.titleLabel?.text = "next".localized
        bankRoutingNumberInput?.setPlaceholder("Bank routing number".localized, isRequired: true)
        firstNameInput?.setPlaceholder("Withdrawal.BankPersonalInfoFirstName".localized, isRequired: true)
        lastNameInput?.setPlaceholder("Withdrawal.BankPersonalInfoLastName".localized, isRequired: true)
        phoneInput?.setPlaceholder("Withdrawal.BankPersonalInfoPhone".localized, isRequired: true)
        emailInput?.setPlaceholder("Withdrawal.BankPersonalInfoEmail".localized, isRequired: true)
    }
    
    private func checkNextButton() {
        guard (firstNameInput?.isValid ?? false)
                &&
                (lastNameInput?.isValid ?? false)
                &&
                (emailInput?.isValid ?? false)
                &&
                (phoneInput?.isValid ?? false)
                && country != nil else {
            
            nextButton?.isEnabled = false
            nextButton?.backgroundColor = .buttonDarkGrey
            return
        }
        nextButton?.isEnabled = true
        nextButton?.setTitleColor(.white, for: .normal)
        nextButton?.backgroundColor = .buttonBlue
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
    
    private func setupData() -> UserInfoObject? {
        UserInfoObject(bankRoutingNumber: bankRoutingNumber, firstName: firstName, lastName: lastName, country: country?.name, phone: phone, email: email)
    }
    
    // MARK: - IBActions
    
    @IBAction private func countriesBtnDidTap(_ sender: AnyObject?) {
        view.endEditing(true)
        countryTableContainer?.isHidden.toggle()
    }
    
    @IBAction private func tapNextButton() {
        if let object = setupData() {
            onTapOption?(object)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BankWithdrawalUserInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        countryL?.text = country?.name
        if country?.code == "USA" {
            isChosenCountryUS = true
        }
        countryTableContainer?.isHidden = true
        checkNextButton()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
}

// MARK: - UITextFieldDelegate
extension BankWithdrawalUserInfoViewController: ValidationTextFieldDelegate {
    func textFieldDidChange(_ textField: ValidationTextField) {
        countryTableContainer?.isHidden = true
        checkNextButton()
    }
}
