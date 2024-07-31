//
//  CryptoDetailsViewController.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 19/2/23.
//

import UIKit
import ELBase

class CryptoDetailsViewController: BaseViewController {
    public var onTapOption: VoidClosure?
    override func storyboardName() -> String {
        return "ELProfileUI"
    }
    @IBAction func checkoutTap(_ sender: Any) {
        onTapOption?()
    }
}
