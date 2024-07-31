//
//  CryptoSectionViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 19/2/23.
//

import UIKit
import ELBase

class CryptoSectionViewController: BaseViewController {
    
    @IBOutlet var cryptoStackView: UIStackView?
    public var onTapOption: VoidClosure?
    struct Crypto {
        var title: String
        var icon: String
        var desc: String
    }
    
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = [
            [Crypto(title: "Coinbase", icon: "", desc: "Best for beginners"),
                     Crypto(title: "Binance", icon: "", desc: "Best for beginners")],
                     [Crypto(title: "Crypto com", icon: "", desc: "Best for beginners"),
                     Crypto(title: "BlockFi", icon: "", desc: "Best for beginners")],
                     [Crypto(title: "Bisq", icon: "", desc: "Best for beginners"),
                     Crypto(title: "FTX", icon: "", desc: "Best for beginners")]
        ]
        
        
        for i in 0..<items.count {
            let stackView = UIStackView()
          
            for _ in 0..<items[i].count {
                let view = CryptoView()
                
                view.onSelect = { self.onTapOption?() }
             
               
                stackView.addArrangedSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.widthAnchor.constraint(equalToConstant: 168).isActive = true
               
                stackView.alignment = .fill
                stackView.spacing = 15
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.heightAnchor.constraint(equalToConstant: 120).isActive = true
                stackView.distribution = .fill
            }
            
            cryptoStackView?.addArrangedSubview(stackView)
        }
    }
}
