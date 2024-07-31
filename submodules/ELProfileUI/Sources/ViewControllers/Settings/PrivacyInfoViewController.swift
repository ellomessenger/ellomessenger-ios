//
//  PrivacyInfoViewController.swift
//  ELProfileUI
//
//

import UIKit
import ELBase
import ELCommonUI
import WebKit
class PrivacyInfoViewController: BaseViewController {
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    @IBOutlet private weak var titleL: UILabel?
    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var loader: UIActivityIndicatorView?
    @IBOutlet private weak var containerStackView: UIStackView?
    
    @IBOutlet private weak var confirmationButton: UIButton?
    @IBOutlet private weak var actionButton: UIButton?
    @IBOutlet private weak var webViewHeight: NSLayoutConstraint?
    
    var onTapNext: VoidClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = Bundle.main.url(forResource: "PrivacyInfo", withExtension: "html") {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
        webView?.navigationDelegate = self
        webView?.configuration.userContentController.addUserScript(self.getZoomDisableScript())
        loader?.startAnimating()
        containerStackView?.isHidden = true
        updateActionButton(false)
    }
    
    override func localize() {
        titleL?.text = "DeleteAccount.Privacy.title".localized
        confirmationButton?.setTitle("DeleteAccount.Privacy.aggreements".localized, for: .normal)
        actionButton?.setTitle("DeleteAccount.Privacy.next".localized, for: .normal)
        actionButton?.setTitle("DeleteAccount.Privacy.next".localized, for: .disabled)
    }
    
    private func updateActionButton(_ isActive: Bool) {
        actionButton?.isEnabled = isActive
        actionButton?.titleLabel?.textColor = isActive ? UIColor.white : UIColor.buttonDarkGrey
        actionButton?.backgroundColor = isActive ? UIColor.buttonBlue : UIColor.textGray
    }
    
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    @IBAction private func acceptAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateActionButton(sender.isSelected)
    }
    
    @IBAction private func deleteButton(sender: UIButton) {
        onTapNext?()
    }
}

extension PrivacyInfoViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { [weak self] (height, error) in
            self?.webViewHeight?.constant = height as! CGFloat
        })
        containerStackView?.isHidden = false
        loader?.removeFromSuperview()
    }
}
