//
//  PaypalConnectViewController.swift
//  _idx_ELProfileUI_3A664715_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi

class PaypalConnectViewController: BaseViewController {
    public enum TopUpProvider {
        case bank
        case paypal
        
        var logoImage: UIImage? {
            switch self {
            case .bank:
                UIImage(named: "Wallet/bank", in: Bundle(for: PaypalConnectViewController.self), with: nil)
            case .paypal:
                UIImage(named: "Wallet/paypal-logo", in: Bundle(for: PaypalConnectViewController.self), with: nil)
            }
        }
        
        var localizedTitle: String {
            switch self {
            case .bank:
                "Wallets.BankCardTitle".localized
            case .paypal:
                "Wallets.PayPalTitle".localized
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private var payPalNavigationLabel: UILabel!
    @IBOutlet private var connectPayPalButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    
    // MARK: - Properties
    var onTapOption: TwoEventsClosure<URL, TopUpProvider>?
    var requestService: RequestService?
    var paymentItem: Api.wallet.PaypalPaymentItem?
    var link: URL?
    var topUpProvider: TopUpProvider = .bank
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getUrl()
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    override func localize() {
        connectPayPalButton?.setTitle("Wallets.PaypalConnect".localized, for: .normal)
        payPalNavigationLabel.text = topUpProvider.localizedTitle
    }
    
    private func setupUI() {
        connectPayPalButton.isEnabled = false
        connectPayPalButton?.setTitleColor(.textGray, for: .disabled)
        connectPayPalButton?.backgroundColor = .buttonDarkGrey
        
        logoImageView.image = topUpProvider.logoImage
    }
    
    // MARK: - IBActions
    @IBAction func connectPaypalTapped(_ sender: UIButton) {
        guard let link else { return }
        
        onTapOption?(link, topUpProvider)
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    private func getUrl() {
        guard let paymentItem else { return }
        
        switch topUpProvider {
        case .bank:
            getBankUrl(paymentItem: paymentItem)
        case .paypal:
            getPayPalUrl(paymentItem: paymentItem)
        }
    }
    
    private func getPayPalUrl(paymentItem: Api.wallet.PaypalPaymentItem) {
        requestService?.getPaypalPayment(with: paymentItem, completionHandler: { [weak self] result in
            switch result {
            case .success(let paymentResponse):
                self?.link = URL(string: paymentResponse.link)
                self?.connectPayPalButton.isEnabled = true
                self?.connectPayPalButton?.setTitleColor(.white, for: .disabled)
                self?.connectPayPalButton?.backgroundColor = .buttonBlue
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    private func getBankUrl(paymentItem: Api.wallet.PaypalPaymentItem) {
        guard let requestService else { return }
        
        Task {
            do {
                let result = try await requestService.bankTopUpUrl(
                    assetId: paymentItem.assetId,
                    walletId: paymentItem.walletId,
                    amount: paymentItem.amount)
                self.link = URL(string: result.link)
                self.connectPayPalButton.isEnabled = true
                self.connectPayPalButton?.setTitleColor(.white, for: .disabled)
                self.connectPayPalButton?.backgroundColor = .buttonBlue
            } catch {
                debugPrint(error)
            }
            
        }
    }
}
