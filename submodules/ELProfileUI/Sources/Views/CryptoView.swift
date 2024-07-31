//
//  CryptoView.swift
//  _idx_ELProfileUI_BBFAEC0E_ios_min11.0
//
//  Created by Damir Aushenov on 19/2/23.
//

import Foundation
import ELBase

class CryptoView: BaseView {
    
    @IBAction func actionTap(_ sender: Any) {
        onSelect?()
    }
    public var onSelect: (()->())?
}
