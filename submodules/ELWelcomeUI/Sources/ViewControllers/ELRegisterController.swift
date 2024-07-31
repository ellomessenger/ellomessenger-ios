//
//  ELRegisterController.swift
//  _idx_ELLoginUI_AEB994F1_ios_min11.0
//
//

import UIKit
import ELCommonUI
import ELBase

public struct RegistrationObject {
    public var profile: ProfileType
    public var vizibility: VisibilityType
    public var username: String
    public var password: String
    public var email: String
    public var country: String?
    public var referalCode: String?
    
    public var date_of_birth: Date = Date()
    public var gender: String = ""
}

public enum ProfileType {
    case personal
    case business
}

public enum VisibilityType {
    case `public`
    case `private`
}

open class ELRegisterController: UIViewController {
    // MARK: - Public
    typealias CheckUsernameParams = (username: String, completion: TwoEventsClosure<Bool, String?>)
    typealias CheckEmailParams = (email: String, completion: EventClosure<Bool>)
    public static var controller: ELRegisterController? {
        let storyboard = UIStoryboard(name: "WelcomeUI", bundle: Bundle(for: ELRegisterController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "ELRegisterController")
        return vc as? ELRegisterController
    }
    
    var onTapBack: (()->())?
    var onTapAction: ((RegistrationObject)->())?
    
    var accountType: ProfileType = .personal {
        didSet { setupProfileType() }
    }
    
    var countries: [Country] = [] {
        didSet { countryTable?.reloadData() }
    }
    
    public static var referralCode:String?
    
    // MARK: - IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var titleL: UILabel!
    @IBOutlet private weak var usernameInput: ValidationTextField! {
        didSet {
            usernameInput.textField.textContentType = .username
        }
    }
    @IBOutlet private weak var passwordInput: ValidationTextField!
    @IBOutlet private weak var confirmPasswordInput: ValidationTextField!
    @IBOutlet private weak var emailInput: ValidationTextField! {
        didSet {
            emailInput.textField.textContentType = .emailAddress
            emailInput.textField.keyboardType = .emailAddress
        }
    }
    
    @IBOutlet open var referalCodeInput: ValidationTextField!
    
    @IBOutlet private weak var publicCheckboxIV: UIImageView!
    @IBOutlet private weak var privateCheckboxIV: UIImageView!
    @IBOutlet private weak var publicPrivateDecriptionL: UILabel!
    
    @IBOutlet private weak var countryContainer: UIView!
    @IBOutlet private weak var countryL: UILabel!
    
    @IBOutlet private weak var countryTableContainer: UIView!
    @IBOutlet private weak var countryTable: UITableView!
    
    @IBOutlet private weak var termsContainer: UIView!
    
    @IBOutlet private weak var termRadioButton: UIButton!
    @IBOutlet private weak var termsTextView: UITextView!
    
    @IBOutlet private weak var registrationBtn: ELButton!
    
    // MARK: - Properties
    private let radioBtnOnImg = UIImage(named: "radio-on", in: Bundle(for: ELRegisterController.self), compatibleWith: nil)
    private let radioBtnOffImg = UIImage(named: "radio-off", in: Bundle(for: ELRegisterController.self), compatibleWith: nil)
    
    private let arrUpImg = UIImage(named: "arr_up", in: Bundle(for: ELRegisterController.self), compatibleWith: nil)?.resize(CGSize(width: 24, height: 12))
    private let arrDwnImg = UIImage(named: "arr_dwn", in: Bundle(for: ELRegisterController.self), compatibleWith: nil)?.resize(CGSize(width: 24, height: 12))
    
    private var tfs: [UITextField?] = []
    private var country: Country?
    
    private var visibility: VisibilityType = .public
    { didSet{ setupProfileType() }}
    
    private var checkImage = UIImage(named: "radio-off", in: Bundle(for: ELRegisterAdditionController.self), compatibleWith: nil)
    var onCheckUsername: ((CheckUsernameParams)->())?
    var onCheckEmail: ((CheckEmailParams)->())?
    
    let termsUrl = "https://ellomessenger.com/terms"
    let privacyUrl = "https://ellomessenger.com/privacy-policy"
    
    private var isSearching = false
    var searchedCountry: [Country] = []
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if #unavailable(iOS 16) {
            NSLayoutConstraint.activate([
                scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16.0)
            ])
        }
        
        overrideUserInterfaceStyle = .light
        
        let fullText = "By registering, you agree to the Terms of Service and Privacy Policy."
        termsTextView.textAlignment = .left
        termsTextView.isEditable = false
        termsTextView.isSelectable = true
        
        termsTextView.hyperLink(originalText: fullText, hyperLink: "Terms of Service", hyperLink2: "Privacy Policy.", urlString: termsUrl, urlString2: privacyUrl)
        
        usernameInput?.validator = UsernameValidator()
        usernameInput?.textField.textContentType = .username
        usernameInput?.maxLength = 32
        usernameInput?.setPlaceholder("Username", isRequired: true)
        usernameInput?.onReturn = { [weak self] in
            self?.passwordInput?.textField.becomeFirstResponder()
        }
        
        usernameInput?.onTextChange = { [weak self] username, isValid in
            guard isValid else {
                self?.checkRegisterBtn()
                return
            }
            
            self?.onCheckUsername?((username ?? "", { isFree, errorDescription in
                guard let self, self.usernameInput.isValid else {
                    return
                }
                if isFree {
                    self.usernameInput?.errorDescription = nil
                } else if let errorDescription {
                    self.usernameInput?.errorDescription = errorDescription
                } else {
                    self.usernameInput?.errorDescription = Localization.usernameRegistered.localized
                }
                
                self.checkRegisterBtn()
            }))
        }
        
        passwordInput?.textField.keyboardType = .asciiCapable
        passwordInput?.textField.textContentType = .password
        passwordInput?.setPlaceholder("password".localized, isRequired: true)
        passwordInput?.validator = PasswordValidator()
        passwordInput?.onReturn = { [weak self] in
            self?.confirmPasswordInput?.textField.becomeFirstResponder()
        }
        
        passwordInput?.onTextChange = { [weak self] value, isValid in
            defer {
                self?.checkRegisterBtn()
            }
            
            guard isValid else { return }
            
            if var validator = (self?.confirmPasswordInput?.validator as? PasswordValidator) {
                validator.updateInputedPassword(value)
                self?.confirmPasswordInput?.validator = validator
            }
        }
        
        
        confirmPasswordInput?.validator = PasswordValidator()
        confirmPasswordInput?.textField.keyboardType = .asciiCapable
        confirmPasswordInput?.textField.textContentType = .password
        confirmPasswordInput?.setPlaceholder("retypePassword".localized, isRequired: true)
        confirmPasswordInput?.onReturn = { [weak self] in
            self?.emailInput?.textField.becomeFirstResponder()
        }
        
        confirmPasswordInput?.onTextChange = { [weak self] _, _ in
            self?.checkRegisterBtn()
        }
        
        emailInput?.validator = EmailValidator()
        emailInput?.onReturn = { [weak self] in
            self?.emailInput?.textField.becomeFirstResponder()
        }
        
        emailInput?.onTextChange = { [weak self] email, isValid in
            guard isValid else {
                self?.checkRegisterBtn()
                return
            }
            
            self?.onCheckEmail?((email ?? "", { isFree in
                guard let self, self.emailInput.isValid else {
                    return
                }
                
                if isFree {
                    self.emailInput.errorDescription = nil
                } else {
                    self.emailInput.errorDescription = Localization.emailRegistered.localized
                }
                
                self.checkRegisterBtn()
            }))
        }
        
        referalCodeInput?.setPlaceholder("ReferalCode".localized, isRequired: false)
        referalCodeInput?.onReturn = { [weak self] in
            self?.referalCodeInput?.textField.resignFirstResponder()
        }
        
        referalCodeInput?.onTextChange = { [weak self] _, _ in
            self?.checkRegisterBtn()
        }
        
        switch accountType {
        case .personal:
            emailInput.setPlaceholder("Email address", isRequired: true)
        case .business:
            emailInput.setPlaceholder("Business email address", isRequired: true)
        }
        
        tfs = [usernameInput.textField, passwordInput.textField, confirmPasswordInput.textField, emailInput.textField, referalCodeInput.textField]
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfileType()
        registrationBtn?.apply(style: .blue)
        checkRegisterBtn()
        setupTextFieldsFocus()
        countryTable?.reloadData()
        setupShadow(countryTableContainer)
        referalCodeInput.textField.text = type(of: self).referralCode
    }
    
    @objc func appMovedToForeground() {
        referalCodeInput.textField.text = type(of: self).referralCode
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupProfileType() {
        countryContainer?.isHidden = accountType == .personal
        termsContainer?.isHidden = accountType == .personal
        
        registrationBtn?.setTitle(accountType == .personal ? "Next" : "Registration", for: .normal)
        
        publicCheckboxIV?.image = visibility == .public ? radioBtnOnImg : radioBtnOffImg
        privateCheckboxIV?.image = visibility == .private ? radioBtnOnImg : radioBtnOffImg
        
        titleL?.text = "\(accountType.title) \(visibility.title) \("account".localized)".capitalizeFirst()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.32
        publicPrivateDecriptionL?.attributedText = NSMutableAttributedString(string:"accountTypeDescription".localized, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private func setupTextFieldsFocus() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let nextItemBtn = UIBarButtonItem(image: arrDwnImg, style: .plain, target: self, action: #selector(nextFocusedTF))
        let prevItemBtn = UIBarButtonItem(image: arrUpImg, style: .plain, target: self, action: #selector(prevFocusedTF))
        let doneItemBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resignActiveTF))
        
        toolBar.setItems([flex, nextItemBtn, prevItemBtn, doneItemBtn], animated: false)
        
        tfs.forEach {
            $0?.inputAccessoryView = toolBar
        }
        
    }
    
    @objc private func nextFocusedTF() {
        if let focused = tfs.first(where: {$0?.isFirstResponder ?? false}) {
            let index = tfs.firstIndex(of: focused) ?? 0
            let resultIndex = index < (tfs.count - 1) ? index+1 : 0
            let tf = tfs[resultIndex]
            tf?.becomeFirstResponder()
        }
    }
    
    @objc private func prevFocusedTF() {
        if let focused = tfs.first(where: {$0?.isFirstResponder ?? false}) {
            let index = tfs.firstIndex(of: focused) ?? 0
            let resultIndex = index > 0 ? index-1 : (tfs.count - 1)
            let tf = tfs[resultIndex]
            tf?.becomeFirstResponder()
        }
    }
    
    @objc private func resignActiveTF() {
        if let focused = tfs.first(where: {$0?.isFirstResponder ?? false}) {
            focused?.resignFirstResponder()
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
    
    private func checkRegisterBtn() {
        registrationBtn.isEnabled = false
        
        guard
            usernameInput.isValid,
            passwordInput.isValid,
            emailInput.isValid
        else {
            return
        }
        
        guard passwordInput.textField.text == confirmPasswordInput.textField.text else {
            confirmPasswordInput?.errorDescription = "passwordsNotMatch".localized
            return
        }
        
        if accountType == .business && !termRadioButton.isSelected {
            return
        }
        
        registrationBtn.isEnabled = true
    }
    
    @IBAction func termRadioButtonAction(_ sender: UIButton) {
        countryTableContainer?.isHidden = true
        termRadioButton.isSelected.toggle()
        checkRegisterBtn()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ELRegisterController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedCountry.count
        } else {
            return countries.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "country") as? ELOptionCell {
            let country = if isSearching {
                searchedCountry[indexPath.row]
            } else {
                countries[indexPath.row]
            }
            cell.configure(title: country.name, iconUrl: country.flag, flagName: country.flagCode)
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        country = if isSearching {
            searchedCountry[indexPath.row]
        } else {
            countries[indexPath.row]
        }
        countryL?.text = country?.name
        countryTableContainer?.isHidden = true
        checkRegisterBtn()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49.0
    }
}

// MARK: - UITextFieldDelegate
extension ELRegisterController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        countryTableContainer?.isHidden = true
        return true
    }
}

// MARK: - UISearchBarDelegate
extension ELRegisterController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countries.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        countryTable.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        countryTable.reloadData()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Actions

extension ELRegisterController {
    
    @IBAction private func onBackDidTap(_ sender: AnyObject?) {
        onTapBack?()
    }
    
    @IBAction private func vizibilityBtnDidTap(_ sender: AnyObject?) {
        countryTableContainer?.isHidden = true
        switch sender?.tag {
        case 0: visibility = .public
        default: visibility = .private
        }
    }
    
    @IBAction private func onRegisterDidTap(_ sender: AnyObject?) {
        let obj = RegistrationObject(profile: accountType,
                                     vizibility: visibility,
                                     username: usernameInput?.textField.text ?? "",
                                     password: passwordInput?.textField.text ?? "",
                                     email: emailInput?.textField.text ?? "",
                                     country: country?.code ?? "",
                                     referalCode: referalCodeInput?.textField.text ?? "")
        onTapAction?(obj)
    }
    
    @IBAction private func countriesBtnDidTap(_ sender: AnyObject?) {
        tfs.forEach{$0?.resignFirstResponder()}
        countryTableContainer?.isHidden.toggle()
    }
    
    
    @IBAction private func textFieldsDidChange(_ sender: AnyObject?) {
        checkRegisterBtn()
    }
}

private enum Localization: String {
    case `public`
    case `private`
    case personal
    case business
    case usernameRegistered = "Username.AlreadyRegistered"
    case emailRegistered = "Email.AlreadyRegistered"
}

// MARK: - Data


private extension ProfileType {
    
    var title: String {
        switch self {
        case .personal: return Localization.personal.localized
        case .business: return Localization.business.localized
        }
    }
}

private extension VisibilityType {
    
    var title: String {
        switch self {
        case .public: return Localization.public.localized
        case .private: return Localization.private.localized
        }
    }
}
