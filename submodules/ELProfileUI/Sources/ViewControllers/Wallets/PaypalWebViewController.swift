//
//  PaypalWebViewController.swift
//  _idx_ELProfileUI_65B39FDE_ios_min14.0
//
//  Created by MacBookAir on 24.07.2023.
//

import UIKit
import WebKit
import ELBase
import ElloAppApi

final class PaypalWebViewController: BaseViewController {
    // MARK: - IBOutlets
    @IBOutlet var webView: WKWebView!
    @IBOutlet private var payPalNavigationLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var isSuccess: Bool?
    var onTapOption: VoidClosure?
    var onTapDoneOption: VoidClosure?
    var topUpProvider: PaypalConnectViewController.TopUpProvider = .bank
    var paymentItem: Api.wallet.PaypalPaymentItem?
    var requestService: RequestService?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUrl()
    }
    
    override func localize() {
        payPalNavigationLabel.text = topUpProvider.localizedTitle
    }
    
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    // MARK: - Actions
    private func openWebView(_ link: URL) {
        webView.navigationDelegate = self
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    //MARK: - IBActions
    @IBAction func tapDoneButton(sender: UIButton) {
        dismiss(animated: true, completion: nil)
        onTapDoneOption?()
    }
    
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
                if let link = URL(string: paymentResponse.link) {
                    self?.openWebView(link)
                }
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
                
                if let link = URL(string: result.link) {
                    openWebView(link)
                }
                
            } catch {
                debugPrint(error)
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension PaypalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        switch topUpProvider {
        case .bank:
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("success"), !url.absoluteString.contains("status=success") {
                    isSuccess = true
                    onTapOption?()
                } else if (url.absoluteString.contains("cancel") || url.absoluteString.contains("failed")) {
                    isSuccess = false
                    onTapOption?()
                }
            }
        case .paypal:
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("success") {
                    isSuccess = true
                    onTapOption?()
                } else if (url.absoluteString.contains("cancel") || url.absoluteString.contains("failure")) {
                    isSuccess = false
                    onTapOption?()
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
        print("Page loading failed with error: \(error.localizedDescription)")
    }
}
