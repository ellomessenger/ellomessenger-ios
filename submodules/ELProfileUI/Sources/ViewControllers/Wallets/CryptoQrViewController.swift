//
//  CryptoQrViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 19/2/23.
//

import UIKit
import ELBase
class CryptoQrViewController: BaseViewController {
    
    @IBOutlet var stackView: UIStackView?
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<2 {
            stackView?.addArrangedSubview(CryptoQrView())
        }
    }
}
