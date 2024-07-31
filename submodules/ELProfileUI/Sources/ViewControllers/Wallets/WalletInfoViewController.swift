//
//  WalletInfoViewController.swift
//  _idx_ELWelcomeUI_257B0FE7_ios_min15.4
//
//  Created by MacBookAir on 08.09.2023.
//

import UIKit
import ELBase
import ElloAppApi

class WalletInfoViewController: BaseViewController {
    
    var didTapBack: VoidClosure?
    var walletType: WalletType? 

    // MARK: - IBOutlet
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Set up
    override func storyboardName() -> String {
        return "Wallet"
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.227, green: 0.227, blue: 0.239, alpha: 0.7) // - temporary color
        titleLabel.text = walletType == .main ? "Wallets.MyBalance".localized : "Wallets.MyBalanceEarning".localized
        descriptionTextView.text = walletType == .main ? "Wallets.MyBalanceDescription".localized : "Wallets.MyBalanceEarningDescription".localized
    }

    // MARK: - Actions
    @objc func dismissViewTap(_ sender: UITapGestureRecognizer) {
        didTapBack?()
    }
}
