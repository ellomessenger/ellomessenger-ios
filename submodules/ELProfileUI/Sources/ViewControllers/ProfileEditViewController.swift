//
//  ProfileEditViewController.swift
//  _idx_ELProfileUI_B5B6554B_ios_min11.0
//
//

import UIKit
import ELBase
import SwiftSignalKit
import ELCommonUI


public enum Gender: String, CaseIterable {
    case Man = "man"
    case Woman = "woman"
    case NonBinary = "non-binary"
    case Other = "prefer-not-to-say"
}

public struct Country {
    public var name: String
    public var code: String
    public var flagCode: String
    public var flag: URL?
    
    public init(name: String, code: String, flagCode: String, flag: URL? = nil) {
        self.name = name
        self.code = code
        self.flag = flag
        self.flagCode = flagCode
    }
}

public struct ProfileEditObject {
    public var firstName: String = ""
    public var lastName: String = ""
    public var userName: String = ""
    public var bio: String = ""
    public var dateOfBirth: Date = Date()
    public var gender: Gender = .Other
    public var country: String = "Country"
    public var currentAvatar: UIImage?
    public let isBusiness: Bool
    
    public init(firstName: String, lastName: String, userName: String, bio: String = "", dateOfBirth: Date = Date(), gender: Gender = .Other, country: String? = nil, currentAvatar: UIImage? = nil, isBusiness: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.bio = bio
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.country = country ?? "Country"
        self.currentAvatar = currentAvatar
        self.isBusiness = isBusiness
    }
}

public protocol UsernameUpdatable {
    func usernameAvailable(_ isFree: Bool)
}

public protocol AvatarUpdatable {
    func updateAvatar(_ image: UIImage)
    func avatarUploading()
}

class ProfileEditViewController: BaseViewController, UsernameUpdatable, AvatarUpdatable {
    
    private let descriptionLabelColor = UIColor(hexStr: "#929298")
    
    // MARK: - Public
    
    var profileObject: ProfileEditObject?
    { didSet{ setupData() }}
    
    var onTapConfirm: EventClosure<ProfileEditObject?>?
    var onTapChangePhoto: VoidClosure?
    var onUsernameChanged: EventClosure<(String, UsernameUpdatable)>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        registerKeyboardNotifications(bottomConstraint: bottomLC)
        
        loadCountries()
        firstNameTF?.onError = { [weak self] _ in
            self?.checkConfirmButton()
        }
        firstNameTF?.onTextChange = { [weak self] _, _ in
            self?.checkConfirmButton()
        }
        firstNameTF?.onReturn = { [weak self] in
            self?.nextFocusedTF()
        }
        lastNameTF?.onError = { [weak self] _ in
            self?.checkConfirmButton()
        }
        lastNameTF?.onTextChange = { [weak self] _, _ in
            self?.checkConfirmButton()
        }
        usernameTF?.onError = { [weak self] _ in
                self?.checkConfirmButton()
        }
        
        usernameTF?.onTextChange = { [weak self] newUsername, isValid in
            guard let self, isValid else {
                return
            }
            self.onUsernameChanged?((newUsername ?? "", self))
        }
        usernameTF?.onReturn = { [weak self] in
            self?.nextFocusedTF()
        }
        usernameTF?.textField.leftPadding = 10
        usernameTF?.textField.leftImage = UIImage(named: "mail", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
        if profileObject?.isBusiness ?? false {
            genderV?.isHidden = true
            lastNameView?.isHidden = true
            dateOfBirthView?.isHidden = true
            if let bioSV, let indexBioV = containereView?.arrangedSubviews.firstIndex(of: bioSV) {
                containereView?.removeArrangedSubview(bioSV)
                containereView?.insertArrangedSubview(bioSV, at: indexBioV + 1)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        setupDatePicker()
        genderTable?.reloadData()
        setupShadow(genderTableContainer)
        setupShadow(countryTableContainer)
        avatarIV?.layer.cornerRadius = 40
        
        setupData()
        
        tfs = [firstNameTF?.textField, lastNameTF?.textField, bioTV, usernameTF?.textField, dateOfBirthTF]
        setupTextFieldsFocus()
        checkConfirmButton()
        genderV?.borderColor = .borderGrey
        countryV?.borderColor = .borderGrey
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        genderV?.borderColor = .borderGrey
        countryV?.borderColor = .borderGrey
        genderTableContainer?.isHidden = true
        countryTableContainer?.isHidden = true
    }
    
    override func localize() {
        if profileObject?.isBusiness ?? false {
            firstNameTF?.setPlaceholder(Localization.businessName.localized, isRequired: false)
            firstNameLabel?.text = Localization.businessName.localized.uppercased()
            bioLabel?.text = Localization.bio.localized.uppercased()
            bioPlaceholderL?.text = Localization.bioOptional.localized(bundle)
        } else {
            firstNameTF?.setPlaceholder(Localization.firstName.localized(bundle), isRequired: false)
            bioLabel?.text = Localization.description.localized.uppercased()
            bioPlaceholderL?.text = Localization.descriptionOptional.localized(bundle)
        }
        lastNameTF?.setPlaceholder(Localization.lastName.localized(bundle), isRequired: false)
        usernameTF?.setPlaceholder(Localization.userName.localized(bundle), isRequired: false)
        dateOfBirthTF?.placeholder = Localization.dateOfBirth.localized(bundle)
        changePhotoL?.text = Localization.changePhoto.localized(bundle)
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    // MARK: - Private
    
    @IBOutlet private weak var avatarIV: UIImageView?
    @IBOutlet private weak var confirmBtn: UIButton?
    @IBOutlet private weak var changePhotoL: UILabel?
    
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var bottomLC: NSLayoutConstraint?
    
    @IBOutlet private weak var containereView: UIStackView?
    @IBOutlet private weak var firstNameLabel: UILabel?
    @IBOutlet private weak var firstNameTF: ValidationTextField?
    @IBOutlet private weak var lastNameView: UIView?
    @IBOutlet private weak var lastNameTF: ValidationTextField?
    @IBOutlet private weak var usernameSV: UIStackView?
    @IBOutlet private weak var usernameTF: ValidationTextField?
    
    @IBOutlet private weak var bioSV: UIStackView?
    @IBOutlet private weak var bioTV: UITextView?
    @IBOutlet private weak var bioPlaceholderL: UILabel?
    @IBOutlet private weak var bioLabel: UILabel?
    @IBOutlet weak var bioSymbolsLabel: UILabel?
    
    @IBOutlet private weak var dateOfBirthView: UIView?
    @IBOutlet private weak var dateOfBirthTF: UITextField?
    
    @IBOutlet private weak var genderV: UIView?
    @IBOutlet private weak var genderL: UILabel?
    @IBOutlet private weak var genderTableContainer: UIView?
    @IBOutlet private weak var genderTable: UITableView?
    
    @IBOutlet private weak var countryV: UIView?
    @IBOutlet private weak var countryL: UILabel?
    @IBOutlet private weak var countryTableContainer: UIView?
    @IBOutlet private weak var countryTable: UITableView?
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?
    private let bundle = Bundle(for: ProfileEditViewController.self)
    private let arrUpImg  = UIImage(named: "arr_up", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)?.resize(CGSize(width: 24, height: 12))
    private let arrDwnImg  = UIImage(named: "arr_dwn", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)?.resize(CGSize(width: 24, height: 12))
    
    private var gender: Gender = .Other
    private var datePickerView: UIDatePicker = UIDatePicker()
    private var dobDate: Date = Date()
    private var tfs: [UIView?] = []
    private var countries: [Country] = []
    
    private var isSearching = false
    var searchedCountry: [Country] = []
    { didSet{ countryTable?.reloadData() }}
    private var country: Country? {
        didSet {
            countryL?.text = country?.name
        }
    }
    public var aboutMaxLength = 70

    private func setupData() {
        firstNameTF?.text = profileObject?.firstName
        var validator = EmptyValueValidator()
        validator.isRequired = true
        firstNameTF?.validator = validator
        firstNameTF?.maxLength = 64
        lastNameTF?.text = profileObject?.lastName
        lastNameTF?.maxLength = 64
        usernameTF?.text = profileObject?.userName
        usernameTF?.validator = UsernameValidator()
        usernameTF?.maxLength = 32
        bioTV?.text = profileObject?.bio
        bioSymbolsLabel?.text = "\(aboutMaxLength - (profileObject?.bio.count ?? 0))"
        dobDate = profileObject?.dateOfBirth ?? Date()
        gender = profileObject?.gender ?? .Other
        bioPlaceholderL?.isHidden = !(profileObject?.bio.isEmpty ?? true)
        dateOfBirthTF?.text = profileObject?.dateOfBirth.stringWithFormat(.EEEMMMddyyyy)
        genderL?.text = profileObject?.gender.localized(bundle)
        countryL?.text = profileObject?.country
        if let img = profileObject?.currentAvatar {
            avatarIV?.image = img
        }
        activityIndicator?.stopAnimating()
    }
    
    private func setupDatePicker() {
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        dateOfBirthTF?.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDateChange), for: .valueChanged)
        datePickerView.backgroundColor = .white
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let doneItemBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resignActiveTF))
        
        toolBar.setItems([flex, doneItemBtn], animated: false)
        dateOfBirthTF?.inputAccessoryView = toolBar
        datePickerView.maximumDate = Date.birthdayMaximum
        datePickerView.minimumDate = Date.birthdayMinimum
        datePickerView.date = profileObject?.dateOfBirth ?? Date()
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
    
    private func checkConfirmButton() {
        guard firstNameTF?.errorDescription == nil && usernameTF?.errorDescription == nil else {
            confirmBtn?.isHidden = true
            return
        }
        if  firstNameTF?.text != profileObject?.firstName
            || lastNameTF?.text != profileObject?.lastName
            || usernameTF?.text != profileObject?.userName
            || bioTV?.text != profileObject?.bio
            || (dateOfBirthTF?.text ?? "") != profileObject?.dateOfBirth.stringWithFormat(.EEEMMMddyyyy)
            || genderL?.text != profileObject?.gender.localized(bundle)
            || countryL?.text != profileObject?.country {
            confirmBtn?.isHidden = false
            return
        }
        confirmBtn?.isHidden = true
    }
    
    private func setupTextFieldsFocus() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        let nextItemBtn = UIBarButtonItem(image: arrDwnImg, style: .plain, target: self, action: #selector(nextFocusedTF))
        let prevItemBtn = UIBarButtonItem(image: arrUpImg, style: .plain, target: self, action: #selector(prevFocusedTF))
        let doneItemBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resignActiveTF))
        
        toolBar.setItems([flex, nextItemBtn, prevItemBtn, doneItemBtn], animated: false)
        
        [firstNameTF, usernameTF, lastNameTF].forEach {
            $0?.maxLengthVisible = true
            $0?.addHorisontalMargins(16)
            $0?.textField.inputAccessoryView = toolBar
        }
        bioTV?.inputAccessoryView = toolBar
    }
    
    @objc private func nextFocusedTF() {
        if let focused = tfs.first(where: {$0?.isFirstResponder ?? false}) {
            let index = tfs.firstIndex(of: focused) ?? 0
            let resultIndex = index < (tfs.count - 1) ? index+1 : 0
            let tf = tfs[resultIndex]
            tf?.becomeFirstResponder()
            scrollView?.scrollRectToVisible(tf?.frame ?? .zero, animated: true)
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
    
    private func loadCountries() {
        ELProfileController.reloadCountries { [weak self] in
            self?.country = $0.first(where: { coutry in coutry.code == self?.profileObject?.country } )
            self?.countries = $0
        }
    }
    
    public func usernameAvailable(_ isFree: Bool) {
        usernameTF?.validate()
        if usernameTF?.isValid ?? false {
            if isFree {
                usernameTF?.errorDescription = nil
            } else {
                usernameTF?.errorDescription = Localization.usernameTaken.localized(bundle)
            }
            checkConfirmButton()
        }
    }
    
    public func updateAvatar(_ image: UIImage) {
        avatarIV?.image = image
        activityIndicator?.stopAnimating()
    }
    
    func avatarUploading() {
        activityIndicator?.startAnimating()
    }
    
    override func keyboardDidShow() {
//        print(scrollView?.visibleSize)
        if bioTV?.isFirstResponder ?? false, let frame = bioTV?.frame {
            let tvFrame = scrollView?.convert(frame, from: bioTV?.superview) ?? .zero
            scrollView?.scrollRectToVisible(tvFrame, animated: true)
        }
    }
}

// MARK: - Actions

extension ProfileEditViewController {
    
    @IBAction private func textFieldDidChabge(_ sender: AnyObject?) {
        checkConfirmButton()
    }
    
    @IBAction private func confirmBtnDidTap(_ sender: AnyObject?) {
        let changedProfile = ProfileEditObject(firstName: firstNameTF?.text ?? "",
                                               lastName: lastNameTF?.text ?? "",
                                               userName: usernameTF?.text ?? "",
                                               bio: bioTV?.text ?? "",
                                               dateOfBirth: dobDate,
                                               gender: gender,
                                               country: country?.code,
                                               isBusiness: false)
        
        onTapConfirm?(changedProfile)
    }
    
    @IBAction private func changeAvatarBtnDidTap(_ sender: AnyObject?) {
        onTapChangePhoto?()
    }
    
    @IBAction private func onGenderBtnDidTap(_ sender: AnyObject?) {
        dateOfBirthTF?.resignFirstResponder()
        genderV?.borderColor = .buttonBlue
        countryV?.borderColor = .borderGrey
        countryTableContainer?.isHidden = true
        genderTableContainer?.isHidden.toggle()
    }
    
    @IBAction private func onCoubtryBtnDidTap(_ sender: AnyObject?) {
        dateOfBirthTF?.resignFirstResponder()
        countryV?.borderColor = .buttonBlue
        genderV?.borderColor = .borderGrey
        countryTable?.reloadData()
        genderTableContainer?.isHidden = true
        countryTableContainer?.isHidden.toggle()
    }
    
    @IBAction private func onDobBtnDidTap(_ sender: AnyObject?) {
        dateOfBirthTF?.becomeFirstResponder()
        genderTableContainer?.isHidden = true
        countryTableContainer?.isHidden = true
        genderV?.borderColor = .borderGrey
        countryV?.borderColor = .borderGrey
    }
    
    @IBAction private func handleDateChange() {
        dobDate = datePickerView.date
        dateOfBirthTF?.text = dobDate.stringWithFormat(.EEEMMMddyyyy)
        checkConfirmButton()
    }
    
    @IBAction private func resignActiveTF() {
        if let focused = tfs.first(where: {$0?.isFirstResponder ?? false}) {
            focused?.resignFirstResponder()
        }
        dateOfBirthTF?.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ProfileEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == genderTable {
            return Gender.allCases.count
        }
        if tableView == countryTable {
            if isSearching {
                return searchedCountry.count
            } else {
                return countries.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "option") as? ELOptionCell {
            if tableView == genderTable {
                let gender = Gender.allCases[indexPath.row]
                cell.title = gender.localized(bundle)
                cell.icon = nil
                return cell
            }
            if tableView == countryTable {
                let country = if isSearching {
                    searchedCountry[indexPath.row]
                } else {
                    countries[indexPath.row]
                }
                cell.configure(title: country.name, iconUrl: country.flag, flagName: country.flagCode)
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == genderTable {
            gender = Gender.allCases[indexPath.row]
            genderL?.text = gender.localized(bundle)
            genderV?.borderColor = .borderGrey
            genderTableContainer?.isHidden = true
        }
        if tableView == countryTable {
            country = if isSearching {
                searchedCountry[indexPath.row]
            } else {
                countries[indexPath.row]
            }
            countryL?.text = country?.name
            countryV?.borderColor = .borderGrey
            countryTableContainer?.isHidden = true
        }
        checkConfirmButton()
    }
}

// MARK: - UISearchBarDelegate
extension ProfileEditViewController: UISearchBarDelegate {
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

// MARK: - UITextViewDelegate

extension ProfileEditViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = (textView.text as NSString).replacingCharacters(in: range, with: text).count
        bioSymbolsLabel?.text = "\(aboutMaxLength - newLength)"
        return newLength <= aboutMaxLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.hasSuffix("\n") {
            textView.text.removeLast()
            nextFocusedTF()
        }
        bioPlaceholderL?.isHidden = !textView.text.isEmpty
        checkConfirmButton()
    }
}

// MARK: - Localization

private enum Localization: String {
    case firstName
    case businessName
    case lastName
    case userName
    case bio
    case bioOptional
    case description
    case descriptionOptional
    case dateOfBirth
    case gender
    case male
    case female
    case other
    case changePhoto
    case usernameTaken = "Username.InvalidTaken"
}

extension UIColor {
    static let buttonBlue = UIColor(named: "ButtonBlue", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let borderGrey = UIColor(named: "BorderGrey", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let bgGray = UIColor(named: "BgGrey", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let textGray = UIColor(named: "TextGray", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let buttonDarkGrey = UIColor(named: "ButtonDarkGrey", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let redText = UIColor(named: "TextRed", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let greenText = UIColor(named: "TextGreen", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
    static let buttonLightRed = UIColor(named: "ButtonLightRed", in: Bundle(for: ProfileEditViewController.self), compatibleWith: nil)
}
