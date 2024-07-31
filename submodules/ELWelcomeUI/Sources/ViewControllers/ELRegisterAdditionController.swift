//
//  ELRegisterAdditionController.swift
//  _idx_ELWelcomeUI_47830975_ios_min11.0
//
//

import UIKit
import ELProfileUI
import ELBase

class ELRegisterAdditionController: UIViewController {
    // MARK: - Public
    public static var controller: ELRegisterAdditionController? { //WelcomeController? {
        let storyboard = UIStoryboard(name: "WelcomeUI", bundle: Bundle(for: ELRegisterAdditionController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "ELRegisterAdditionController")
        return vc as? ELRegisterAdditionController
    }
    
    var onTapBack: (() -> Void)?
    var onTapRegister: ((Object) -> Void)?
    
    var countries: [Country] = [] {
        didSet { countryTable?.reloadData() }
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var dateTF: UITextField?
    @IBOutlet private weak var countryL: UILabel?

    @IBOutlet private weak var countryTableContainer: UIView?
    @IBOutlet private weak var countryTable: UITableView?
    
    @IBOutlet private weak var genderL: UILabel?
    @IBOutlet private weak var genderTableContainer: UIView?
    @IBOutlet private weak var genderTable: UITableView?
    
    @IBOutlet private weak var termRadioButton: UIButton!
    @IBOutlet private weak var privacyTextView: UITextView!
    
    @IBOutlet private weak var registrationBtn: ELButton?
    
    private let radioBtnOffImg = UIImage(named: "radio-off", in: Bundle(for: ELRegisterAdditionController.self), compatibleWith: nil)
    private let checkBtnOnImg  = UIImage(named: "checkmark", in: Bundle(for: ELRegisterAdditionController.self), compatibleWith: nil)
    private let bundle = Bundle(for: ELRegisterAdditionController.self)
    
    private var datePickerView: UIDatePicker = UIDatePicker()
    
    private var dobDate: Date = Date()
    private var country: Country?
    private var gender: Gender  = .Other
    
    private var checkImage = UIImage(named: "radio-off", in: Bundle(for: ELRegisterAdditionController.self), compatibleWith: nil)
    
    let termsUrl = "https://ellomessenger.com/terms"
    let privacyUrl = "https://ellomessenger.com/privacy-policy"
    
    private var isSearching = false
    var searchedCountry: [Country] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullText = "By registering, you agree to the Terms of Service and Privacy Policy."
        privacyTextView.textAlignment = .left
        privacyTextView.isEditable = false
        privacyTextView.isSelectable = true

        privacyTextView.hyperLink(originalText: fullText, hyperLink: "Terms of Service", hyperLink2: "Privacy Policy.", urlString: termsUrl, urlString2: privacyUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registrationBtn?.apply(style: .blue)
        checkRegisterBtn()
        setupDatePicker()
        
        countryTable?.reloadData()
        genderTable?.reloadData()
        
        setupShadow(genderTableContainer)
        setupShadow(countryTableContainer)
    }
    
    private func checkRegisterBtn() {
        guard !(dateTF?.text?.isEmpty ?? true),
              (countryL?.text != "Country"),
              (genderL?.text != "Gender" ),
              checkImage == checkBtnOnImg
        else {
            registrationBtn?.isEnabled = false
            return
        }
        registrationBtn?.isEnabled = true
    }
    
    private func setupDatePicker() {
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        dateTF?.inputView = datePickerView
        
        datePickerView.maximumDate = Date.birthdayMaximum
        datePickerView.minimumDate = Date.birthdayMinimum
        datePickerView.addTarget(self, action: #selector(handleDateChange), for: .valueChanged)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let doneItemBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resignActiveTF))
        
        toolBar.setItems([flex, doneItemBtn], animated: false)
        dateTF?.inputAccessoryView = toolBar
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
    
    
    @IBAction func termRadioButtonAction(_ sender: UIButton) {
        dateTF?.resignFirstResponder()
        countryTableContainer?.isHidden = true
        genderTableContainer?.isHidden = true
        
        checkImage = checkImage == checkBtnOnImg ? radioBtnOffImg : checkBtnOnImg
        termRadioButton.setBackgroundImage(checkImage, for: .normal)
        checkRegisterBtn()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ELRegisterAdditionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == countryTable {
            if isSearching {
                return searchedCountry.count
            } else {
                return countries.count
            }
        }
        if tableView == genderTable {
            return Gender.allCases.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "country") as? ELOptionCell {
            if tableView == countryTable {
                let country = if isSearching {
                    searchedCountry[indexPath.row]
                } else {
                    countries[indexPath.row]
                }
                cell.configure(title: country.name, iconUrl: country.flag, flagName: country.flagCode)
                
                return cell
            }
            
            if tableView == genderTable {
                let gender = Gender.allCases[indexPath.row]
                cell.title = gender.localized(bundle)
                cell.icon = nil
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == countryTable {
            country = if isSearching {
                searchedCountry[indexPath.row]
            } else {
                countries[indexPath.row]
            }
            countryL?.text = country?.name
            countryTableContainer?.isHidden = true
        }
        if tableView == genderTable {
            gender = Gender.allCases[indexPath.row]
            genderL?.text = gender.localized(bundle)
            genderTableContainer?.isHidden = true
        }
        checkRegisterBtn()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49.0
    }
}

// MARK: - UISearchBarDelegate
extension ELRegisterAdditionController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countries.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        countryTable?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        countryTable?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Actions
extension ELRegisterAdditionController {
    
    @IBAction private func onBackDidTap(_ sender: AnyObject?) {
        onTapBack?()
    }
    
    @IBAction private func onDobBtnDidTap(_ sender: AnyObject?) {
        dateTF?.becomeFirstResponder()
        if dateTF?.text?.isEmpty ?? true {
            handleDateChange()
        }
        countryTableContainer?.isHidden = true
        genderTableContainer?.isHidden = true
    }
    
    @IBAction private func onGenderBtnDidTap(_ sender: AnyObject?) {
        dateTF?.resignFirstResponder()
        countryTableContainer?.isHidden = true
        genderTableContainer?.isHidden.toggle()
    }
    
    @IBAction private func onCountryBtnDidTap(_ sender: AnyObject?) {
        dateTF?.resignFirstResponder()
        genderTableContainer?.isHidden = true
        countryTableContainer?.isHidden.toggle()
    }
    
    
    @IBAction private func onRegisterDidTap(_ sender: AnyObject?) {
        let obj = Object(dob: dobDate,
                         country: country?.code ?? "",
                         gender: gender)
        onTapRegister?(obj)
    }
    
    @IBAction private func handleDateChange() {
        dobDate = datePickerView.date
        dateTF?.text = dobDate.stringWithFormat(.EEEMMMddyyyy)
        checkRegisterBtn()
    }
    
    @IBAction private func resignActiveTF() {
        dateTF?.resignFirstResponder()
    }
}

// MARK: - Data

extension ELRegisterAdditionController {
    
    struct Object {
        var dob: Date
        var country: String
        var gender: Gender
    }
}


