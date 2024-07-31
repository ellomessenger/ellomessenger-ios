//
//  WithdrawalInfoViewController.swift
//  _idx_ElloAppApi_E33B064A_ios_min14.0
//

import UIKit
import ElloAppApi
import ELBase

class WithdrawalInfoViewController: BaseViewController {
    public var onTapOption: EventClosure<BankWithdrawsItem>?
    
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var titleL: UILabel?
    
    @IBOutlet private weak var titleFirstNameLabel: UILabel?
    @IBOutlet private weak var firstNameLabel: UILabel?
    @IBOutlet private weak var titleLastNameLabel: UILabel?
    @IBOutlet private weak var lastNameLabel: UILabel?
    @IBOutlet private weak var titlePhoneLabel: UILabel?
    @IBOutlet private weak var phoneLabel: UILabel?
    @IBOutlet private weak var titleEmailLabel: UILabel?
    @IBOutlet private weak var emailLabel: UILabel?
    
    @IBOutlet private weak var titleUserAddressLabel: UILabel?
    @IBOutlet private weak var userAddressLabel: UILabel?
    
    @IBOutlet private weak var titleBankCountryLabel: UILabel?
    @IBOutlet private weak var bankCountryLabel: UILabel?
    @IBOutlet private weak var titleBankRecipientTypeLabel: UILabel?
    @IBOutlet private weak var bankRecipientTypeLabel: UILabel?
    @IBOutlet private weak var titleBankBusinessIdentificationNumberLabel: UILabel?
    @IBOutlet private weak var bankBusinessIdentificationNumberLabel: UILabel?
    @IBOutlet private weak var titleBankCurrencyLabel: UILabel?
    @IBOutlet private weak var bankCurrencyLabel: UILabel?
    @IBOutlet private weak var titleBankNameLabel: UILabel?
    @IBOutlet private weak var bankNameLabel: UILabel?
    @IBOutlet private weak var titleBankAddressLabel: UILabel?
    @IBOutlet private weak var bankAddressLabel: UILabel?
    
    @IBOutlet private weak var titleBankBankNameLabel: UILabel?
    @IBOutlet private weak var bankBankNameLabel: UILabel?
    
    @IBOutlet private weak var titleUserRoutingNumberLabel: UILabel?
    @IBOutlet private weak var userRoutingNumberLabel: UILabel?
    @IBOutlet private weak var titleUserRecipientAccountNumberLabel: UILabel?
    @IBOutlet private weak var userRecipientAccountNumberLabel: UILabel?
    @IBOutlet private weak var titleUserSwiftCodeLabel: UILabel?
    @IBOutlet private weak var userSwiftCodeLabel: UILabel?
    @IBOutlet private weak var titleUserIbanCodeLabel: UILabel?
    @IBOutlet private weak var userIbanCodeLabel: UILabel?

    @IBOutlet private weak var titleAmountLabel: UILabel?
    @IBOutlet private weak var amountLabel: UILabel?
    @IBOutlet private weak var nextButton: UIButton?
    @IBOutlet private weak var backButton: UIButton?
    
    public var bankWithdrawsItem: BankWithdrawsItem?
    public var amount: Double?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideViews()
        showBankWithdrawsItem()
        setupLocalisation()
    }
    
    private func hideViews() {
        if bankWithdrawsItem?.isUSA ?? false {
            [ bankBankNameLabel?.superview?.superview,
              bankRecipientTypeLabel?.superview,
              bankBusinessIdentificationNumberLabel?.superview,
              bankCurrencyLabel?.superview,
              userSwiftCodeLabel?.superview,
              userIbanCodeLabel?.superview
            ].forEach({$0?.isHidden = true})
        }
        else {
            if  bankWithdrawsItem?.isBusiness ?? false {
                [ bankBusinessIdentificationNumberLabel?.superview,
                  bankNameLabel?.superview,
                  bankAddressLabel?.superview,
                  userRoutingNumberLabel?.superview,
                  userIbanCodeLabel?.superview
                ].forEach({$0?.isHidden = true})
            }
            else {
                [ bankNameLabel?.superview,
                  bankAddressLabel?.superview,
                  userRoutingNumberLabel?.superview,
                  userIbanCodeLabel?.superview
                ].forEach({$0?.isHidden = true})
            }
        }
    }

    func showBankWithdrawsItem() {
        firstNameLabel?.text = bankWithdrawsItem?.personInfo?.firstName
        lastNameLabel?.text = bankWithdrawsItem?.personInfo?.lastName
        phoneLabel?.text = bankWithdrawsItem?.personInfo?.phoneNumber
        emailLabel?.text = bankWithdrawsItem?.personInfo?.email
        
        userAddressLabel?.text = bankWithdrawsItem?.addressInfo?.text
        
        bankCountryLabel?.text = bankWithdrawsItem?.bankInfo?.country
        bankRecipientTypeLabel?.text = bankWithdrawsItem?.recipientType
        bankBusinessIdentificationNumberLabel?.text = bankWithdrawsItem?.businessIdNumber
        bankCurrencyLabel?.text = bankWithdrawsItem?.currency
        bankNameLabel?.text = bankWithdrawsItem?.bankInfo?.name
        bankAddressLabel?.text = bankWithdrawsItem?.addressInfo?.text

        bankNameLabel?.text = bankWithdrawsItem?.bankInfo?.name
        
        userRoutingNumberLabel?.text = bankWithdrawsItem?.bankInfo?.routingNumber
        userRecipientAccountNumberLabel?.text = bankWithdrawsItem?.bankInfo?.recipientAccountNumber
        userSwiftCodeLabel?.text = bankWithdrawsItem?.bankInfo?.swift
        userIbanCodeLabel?.text = bankWithdrawsItem?.bankInfo?.recipientAccountNumber
        
        amountLabel?.text = amount?.stringFinanceFormat
    }
    
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    func setupLocalisation() {
//        titleL?.text = "transferOut".localized
//        nextButton?.titleLabel?.text = "transferOut".localized
//        backButton?.titleLabel?.text = "back".localized
//        titleFirstNameLabel?.text = "Withdrawal.BankPersonalInfoFirstName".localized
//        titleLastNameLabel?.text = "Withdrawal.BankPersonalInfoLastName".localized
//        titlePhoneLabel?.text = "Withdrawal.BankPersonalInfoPhone".localized
//        titleEmailLabel?.text = "Withdrawal.BankPersonalInfoEmail".localized
//        
//       titleUserAddressLabel?.text = "Withdrawal.BankPersonalAddress".localized
//        titleUserStreetLabel?.text = "Withdrawal.BankPersonalStreet".localized
//        titleUserCityLabel?.text = "Withdrawal.BankPersonalCity".localized
//    
//        titleBankNameLabel?.text = "Withdrawal.BankName".localized
//        titleBankCityLabel?.text = "Withdrawal.BankPersonalCity".localized
//        titleBankStreetLabel?.text = "Withdrawal.BankPersonalStreet".localized
//        [titleUserStateLabel, titleBankStateLabel].compactMap { $0 }.forEach {
//            $0.text = (isUSA || isChosenCountryUS) ? "Withdrawal.BankPersonalState".localized : "Withdrawal.BankPersonalRegion".localized
//        }
//        
//        [titleBankPostalCodeLabel, titleUserPostalCodeLabel].compactMap { $0 }.forEach {
//            $0.text = (isUSA || isChosenCountryUS) ? "Withdrawal.BankPersonalPostalCode".localized : "Withdrawal.BankPersonalZIPCode".localized
//        }
    }
    
    // MARK: - Network Manager calls
    
    // MARK: - IBActions
    @IBAction private func onTapButton() {
        if let bankWithdrawsItem {
            nextButton?.isEnabled = false
            onTapOption?(bankWithdrawsItem)
        }
    }
}
