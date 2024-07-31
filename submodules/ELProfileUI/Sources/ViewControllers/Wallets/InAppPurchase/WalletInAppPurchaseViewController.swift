//
//  WalletInAppPurchaseViewController.swift
//  ELProfileUI
//
//

import UIKit
import ELBase
import ElloAppCore

class WalletInAppPurchaseViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet var packagesStackView: UIStackView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var activityBackgroundView: UIView!
    
    // MARK: - Properties
    var inAppItems: [InAppPurchasePackageItem] = [] {
        didSet {
            updateInAppPackages()
        }
    }
    private let iapService = iAPService(productIds: CoinsConsumableProductIds())
    private var selectedProductId = "" {
        didSet {
            buyButton.isEnabled = !selectedProductId.isEmpty
        }
    }
    var requestService: RequestService?
    var onInAppPurchaseMade: ((_ isSuccess: Bool, _ amount: Int) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAvailableProducts()
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    // MARK: - IBActions
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        showLoadingState()
        iapService.buyProduct(selectedProductId) { [weak self] result in
            switch result {
            case .success(_, _, _, let payload, let productId):
                self?.processApplePayment(productId: productId, payload: payload)
            case .failure:
                self?.hideLoadingState()
                break
            }
        }
    }
    
    @IBAction func packageItemTapped(_ sender: InAppPurchasePackageView) {
        if sender.isSelected { return }
        
        packagesStackView.arrangedSubviews.forEach { ($0 as? InAppPurchasePackageView)?.isSelected = false }
        
        sender.isSelected.toggle()
        selectedProductId = sender.productId
    }
    
    // MARK: - Actions
    private func updateAvailableProducts() {
        inAppItems.removeAll()
        
        Task {
            await iapService.retrieveConsumableProducts()
            inAppItems = iapService.consumableProducts.compactMap { InAppPurchasePackageItem(product: $0) }
        }
    }
    
    private func updateInAppPackages() {
        packagesStackView.isHidden = inAppItems.isEmpty
        if inAppItems.isEmpty {
            activityIndicator.startAnimating()
            return
        } else {
            activityIndicator.stopAnimating()
        }
        
        packagesStackView.arrangedSubviews.enumerated().forEach { [weak self] index, view in
            guard let view = view as? InAppPurchasePackageView else { return }
            guard let productItem = self?.inAppItems[safe: index] else { return }
            
            view.updateData(productItem)
        }
    }
    
    private func showLoadingState() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.activityBackgroundView.alpha = 1.0
        }
    }
    
    private func hideLoadingState() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.activityBackgroundView.alpha = 0.0
        }
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    private func processApplePayment(productId: String, payload: String) {
        guard let item = inAppItems.first(where: { $0.productId == productId }) else { return }
        
        Task {
            do {
                let result = try await self.requestService?.processApplePayment(amount: Double(item.count), payload: payload)
                self.onInAppPurchaseMade?(!(result?.status.isEmpty ?? true), item.count)
            } catch {
                debugPrint(error)
                self.onInAppPurchaseMade?(false, 0)
            }
            
            self.hideLoadingState()
        }
    }
}
