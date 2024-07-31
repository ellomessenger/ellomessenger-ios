//
//  PaymentStatusViewController.swift
//  _idx_ELProfileUI_99BC7FC4_ios_min14.0
//
//

import UIKit
import ELBase
import ElloAppApi

enum RequestStatus {
    case inProgress
    case success
    case failed
    
    var imageName: String {
        switch self {
        case .inProgress:
            return "Wallet/check-circle"
        case .success:
            return "Wallet/panda-success"
        case .failed:
            return "Wallet/panda-failure"
        }
    }
    
    var title: String {
        switch self {
        case .inProgress:
            return "Request has been sent"
        case .success:
            return "Success!"
        case .failed:
            return "Error!"
        }
    }
    
    func subtitle(withAmount amount: Double = 0, methodType: MethodTypes?) -> String {
        switch self {
        case .inProgress:
            return "in progress..."
        case .success:
            return MethodTypesViewModel.subtitle(withAmount: amount, methodType: methodType)
        case .failed:
            guard let type = methodType == .deposit ? methodType?.rawValue : methodType?.rawValue else { return "" }
            return String(format: "Wallets.ErrorDepositUnsuccessful".localized, type)
        }
    }
    
    var backButtonAlpha: CGFloat {
        switch self {
        case .inProgress:
            return 0.0
        default:
            return 1.0
        }
    }
}

public enum PaymentSystemStatus {
    case bank(Api.wallet.PaymentItem)
    case paypal
    case inAppPurchase
}

class PaymentStatusViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var coinImageView: UIImageView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var coinsContainerStackView: UIStackView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var containerStackView: UIStackView!
    @IBOutlet var backNavbarContainerView: UIView!
    
    // MARK: - Properties
    var onTapOption: VoidClosure?
    private var requestStatus: RequestStatus = .inProgress {
        didSet {
            updateUI()
        }
    }
    
    var requestService: RequestService?
    var topUpBalance: Double = 0
    var paymentSystemStatus: PaymentSystemStatus?
    var isSuccess: Bool?
    var methodType: MethodTypes?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.makePayment()
        }
        
        coinsContainerStackView.isHidden = true
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    override func localize() {
        backButton.setTitle("Common.OK".localized, for: .normal)
    }
    
    private func updateUI() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.containerStackView.alpha = 0
        } completion: { finished in
            self.setImage(
                name: self.requestStatus.imageName,
                title: self.requestStatus.title,
                subtitle: self.requestStatus.subtitle(withAmount: self.topUpBalance, methodType: self.methodType)
            )
            self.coinsContainerStackView.isHidden = self.requestStatus != .success
            
            UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut) {
                self.backButton.alpha = self.requestStatus.backButtonAlpha
                self.containerStackView.alpha = 1
            }
        }
        
        backNavbarContainerView.isHidden = requestStatus == .success
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        onTapOption?()
    }
    
    // MARK: - Actions
    func setImage(name: String, title: String, subtitle: String) {
        imageView.image = UIImage(named: name, in: Bundle(for: PaymentStatusViewController.self), compatibleWith: nil)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        amountLabel.text = String(format: "%.2f", topUpBalance)
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    private func makePayment() {
        guard let paymentSystemStatus else { return }
        
        switch paymentSystemStatus {
        case .bank(let paymentItem):
            requestService?.makePayment(with: paymentItem, completionHandler: { result in
                switch result {
                case .success:
                    self.topUpBalance = paymentItem.amount
                    self.requestStatus = .success
                case .failure:
                    self.requestStatus = .failed
                }
            })
        case .paypal, .inAppPurchase:
            guard let isSuccess else { return }
            
            requestStatus = isSuccess ? .success : .failed
        }
    }
}
