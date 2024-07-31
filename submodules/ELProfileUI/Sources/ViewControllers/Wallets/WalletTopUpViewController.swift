//
//  WalletTopUpViewController.swift
//  _idx_ELProfileUI_99BC7FC4_ios_min14.0
//
//

import UIKit
import ElloAppApi
import ELBase

public typealias WithdrawParams = (amount: Double, paymentId: String?)

class WalletTopUpViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet private var navigationTitleLabel: UILabel!
    
    @IBOutlet private var balanceStackView: UIStackView!
    @IBOutlet private var balanceTitleLabel: UILabel!
    @IBOutlet private var balanceCoinImageView: UIImageView!
    @IBOutlet private var balanceValueLabel: UILabel!
    
    @IBOutlet private var minAmountStackView: UIStackView!
    @IBOutlet private var minAmountTitleLabel: UILabel!
    @IBOutlet private var minAmountCoinImageView: UIImageView!
    @IBOutlet private var minAmountValueLabel: UILabel!

    @IBOutlet private var transactionFeeStackView: UIStackView!
    @IBOutlet private var transactionFeeTitleLabel: UILabel!
    @IBOutlet private var transactionFeeCoinImageView: UIImageView!
    @IBOutlet private var transactionFeeValueLabel: UILabel!
    
    @IBOutlet private var systemFeeStackView: UIStackView!
    @IBOutlet private var systemFeeTitleLabel: UILabel!
    @IBOutlet private var systemFeeCoinImageView: UIImageView!
    @IBOutlet private var systemFeeValueLabel: UILabel!
    
    @IBOutlet private var approximatelyStackView: UIStackView!
    @IBOutlet private var approximatelyTitleLabel: UILabel!
    @IBOutlet private var approximatelyCoinImageView: UIImageView!
    @IBOutlet private var approximatelyValueLabel: UILabel!
    
    @IBOutlet private var cardLogoImage: UIImageView!
    @IBOutlet private var topUpTextField: UITextField! {
        didSet {
            topUpTextField.placeholder = minimumAmountOfDeposit.stringFinanceFormat
            topUpTextField.text = minimumAmountOfDeposit.stringFinanceFormat
        }
    }
    
    @IBOutlet private var confirmButton: UIButton!
    
    // MARK: - Properties
    private var topUpTextFieldChanged:Bool = false
    private let minimumAmountOfDeposit = 10.0
    private let minimumAmountOfWithdrawal = 10.0
    private let maximalAmountOfDeposit = 99999.99
    
    var onTapOption: EventClosure<WithdrawParams>?
    var balance = 0.0
    var transactionFee = 0.0
    var transactionSystemFee = 0.0
    var enteredAmount = 0.0
    var amount = 0.0
    var methodTypes: MethodTypes?
    var paymentSystem: TopUpMethodModel?
    var wallet: Api.wallet.WalletItem?
    var wallets: [Api.wallet.WalletItem]?
    var requestService: RequestService?
    var paymentId: String?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        balanceValueLabel.text = balance.stringFinanceFormatWithDollar

        cardLogoImage.contentMode = .center
        cardLogoImage.backgroundColor = .bgGray
        enteredAmount = Double(topUpTextField.text ?? "") ?? 0
        withdrawCreatePayment(paymentId: paymentId, amount: minimumAmountOfDeposit)
        topUpTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topUpTextField.becomeFirstResponder()
        confirmButton.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    func setupUI() {
        navigationTitleLabel.text = methodTypes == .deposit ? "Wallets.DepositMethod".localized : "Wallets.WithdrawalMethod".localized
        minAmountTitleLabel.text = methodTypes == .deposit ? "Wallets.Deposit.MinimumAmount".localized : "Withdrawal.MinimumAmount".localized
        minAmountValueLabel.text = minimumAmountOfWithdrawal.stringFinanceFormatWithDollar

        switch paymentSystem {
        case .payPal:
            let paypalLogo = UIImage(named: "Wallet/payPal", in: Bundle(for: Self.self), compatibleWith: nil)
            cardLogoImage.image = paypalLogo
        case .bankCard:
            let cardLogo = UIImage(named: paymentSystem!.icon, in: Bundle(for: Self.self), compatibleWith: nil)
            cardLogoImage.image = cardLogo
        case .myBalance:
            let myBalanceLogo = UIImage(named: "Wallet/myBalance_icon", in: Bundle(for: Self.self), compatibleWith: nil)
            cardLogoImage.image = myBalanceLogo
        case .elloai, .none, .apple:
            break
        }
    }
    
    func setupFeeCalculatingLabel() {
        transactionFeeStackView.isHidden = transactionFee.isLessThanOrEqualTo(.zero)
        transactionFeeValueLabel.text = transactionFee.stringFinanceFormatWithDollar
    }
    
    func setupSystemFeeCalculatingLabel() {
        systemFeeStackView.isHidden = transactionSystemFee.isLessThanOrEqualTo(.zero)
        systemFeeTitleLabel.text = paymentSystem == .payPal ? "Wallets.Methods.PayPalCommission".localized : "Wallets.Methods.StripeCommission".localized
        systemFeeValueLabel.text = transactionSystemFee.stringFinanceFormat(withAssetSymbolCode: wallet?.assetSymbol, defaultCurrencySymbol: "$")
    }
    
    private var approximatelyValue: Double { amount }
    func setupApproximatelyLabel() {
        approximatelyStackView.isHidden = approximatelyValue.isLessThanOrEqualTo(.zero)
//        approximatelyCoinImageView.isHidden = paymentSystem != .myBalance
        approximatelyValueLabel.text = if paymentSystem != .myBalance {
            approximatelyValue.stringFinanceFormat(withAssetSymbolCode: wallet?.assetSymbol, defaultCurrencySymbol: "$")
        } else {
            approximatelyValue.stringFinanceFormatWithDollar
        }
    }

    // MARK: - IBActions
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let text = topUpTextField.text else { return }

        guard let topUpAmount = Double(text.replacingOccurrences(of: ",", with: ".")) else { return }
        guard topUpAmount >= minimumAmountOfDeposit else {
            showAlert(title: "Wrong amount", message: "Top Up amount should be equal or greater than $10")
            return
        }
   
        if .withdrawal == methodTypes {
            guard topUpAmount <= balance else {
                showAlert(title: "Wrong amount", message: "Top Up amount with applied fee should be equal or less than your balance")
                return
            }
        }
        
        sender.isUserInteractionEnabled = false
        onTapOption?(WithdrawParams(topUpAmount, paymentId))
    }
    
    @IBAction func topUpTextFieldEditingChanged(_ sender: UITextField) {
        let text = topUpTextField.text ?? ""
        let doubleText = text.replacingOccurrences(of: ",", with: ".")
        enteredAmount = Double(doubleText) ?? 0.0
        withdrawCreatePayment(paymentId: paymentId, amount: enteredAmount)
    }
    
    private func checkUI() {
        let isMinimumAmount = minimumAmountOfDeposit <= enteredAmount
        minAmountTitleLabel.textColor = isMinimumAmount ? .textGray : .red
        minAmountValueLabel.textColor = isMinimumAmount ? .textGray : .red
        let calculatedFee = 0.0 //enteredAmount * transactionFee // EM-3044
        let isMaximumAmount = enteredAmount <= (.withdrawal == methodTypes ? balance - calculatedFee : maximalAmountOfDeposit)
        confirmButton.isEnabled = (isMinimumAmount && isMaximumAmount)
        if .withdrawal == methodTypes {
            balanceTitleLabel.textColor = isMaximumAmount ? .textGray : .red
            balanceValueLabel.textColor = isMaximumAmount ? .textGray : .red
        }
    }
    
    // MARK: - Actions
    private func showAlert(title: String?, message: String?) {
        let alertController = AlertViewController.createOkAlertController(
            title: title,
            message: message
        )
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Network Manager calls
    func withdrawCreatePayment(paymentId: String?, amount: Double?) {
        guard let wallet else { return }
        guard let toWalletId = wallets?.first(where: {$0.type == .main})?.id else { return }
        guard let paymentSystem else { return }
        
        func processResult(amount:Double? = nil,
                           fee: Double? = nil,
                           paymentSystemFee: Double? = nil, //PayPal
                           amountFiat:Double? = nil,        //Transfer
                           max:Double? = nil,
                           min:Double? = nil) {
            
            self.amount = amount ?? 0
            self.transactionFee = fee ?? 0
            self.transactionSystemFee = paymentSystemFee ?? 0
            
            self.setupFeeCalculatingLabel()
            self.setupSystemFeeCalculatingLabel()
            self.setupApproximatelyLabel()
            self.checkUI()
        }
        
        checkUI()
        
        switch paymentSystem {
        case .myBalance:
            Task {
                do {
                    
                    let result = try await self.requestService?.internalTransferPayment(fromWalletId: wallet.id,
                                                                                        toWalletId: toWalletId,
                                                                                        amount: amount ?? 0.0,
                                                                                        currency: wallet.assetSymbol,
                                                                                        message: nil)
                    processResult(amount: result?.amount,
                                  fee: result?.fee,
                                  amountFiat: result?.amountFiat,
                                  max: result?.transferMax,
                                  min: result?.transferMin)
                } catch {
                    debugPrint(error)
                }
            }
            
        case .payPal:
            requestService?.createWithdrawPayment(assetId: BaseAsset.usd.rawValue,
                                                  walletId: wallet.id,
                                                  currency: wallet.assetSymbol,
                                                  paymentId: paymentId,
                                                  amount: amount ?? 0.0,
                                                  withdrawSystem: WithdrawSystem.paypal.rawValue) {[weak self] result in
                switch result {
                case .success(let withdrawItem):
                    self?.paymentId = paymentId
                    processResult(amount:withdrawItem.amount, 
                                  fee: withdrawItem.fee,
                                  paymentSystemFee: withdrawItem.paymentSystemFee,
                                  max:withdrawItem.withdrawMax,
                                  min:withdrawItem.withdrawMin)
                case .failure(let error):
                    debugPrint(error)
                }
            }
            
        case .bankCard:
            requestService?.createWithdrawPayment(assetId: BaseAsset.usd.rawValue,
                                                  walletId: wallet.id,
                                                  currency: wallet.assetSymbol,
                                                  paymentId: paymentId,
                                                  amount: amount ?? 0.0,
                                                  withdrawSystem: WithdrawSystem.bank.rawValue) {[weak self] result in
                switch result {
                case .success(let withdrawItem):
                    self?.paymentId = paymentId
                    processResult(amount:withdrawItem.amount,
                                  fee: withdrawItem.fee,
                                  paymentSystemFee: withdrawItem.paymentSystemFee,
                                  max:withdrawItem.withdrawMax,
                                  min:withdrawItem.withdrawMin)
                case .failure(let error):
                    debugPrint(error)
                }
            }

        default:
            assert(true, "Bad state")
        }
    }
}

extension WalletTopUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !topUpTextFieldChanged {
            topUpTextFieldChanged = true
            DispatchQueue.main.async {
                textField.text = string
            }
            
            return textField.shouldPriceChangeCharactersIn(NSMakeRange(0, textField.text!.count), replacementString: string)
        }
        else {
            return textField.shouldPriceChangeCharactersIn(range, replacementString: string)
        }
    }
}
