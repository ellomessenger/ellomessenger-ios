//
//  CodeTextField.swift
//  _idx_ELWelcomeUI_257B0FE7_ios_min15.4
//

import UIKit

protocol CodeTextFieldDelegate: AnyObject {
    func textFieldDidDelete()
}

final class CodeTextField: UITextField {
    weak var customDelegate: CodeTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.textFieldDidDelete()
    }
    
    func configure() {
        textContentType = .oneTimeCode
        textColor = .black
        textAlignment = .center
        backgroundColor = .clear
        keyboardType = .numberPad
        font = UIFont(name: "SFProDisplay-Medium", size: 20.0)
    }
}
