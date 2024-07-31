//
//  AccountInfoButtonCell.swift
//  ELProfileUI
//
//

import UIKit
import ELBase

class AccountInfoButtonCell: UITableViewCell {
    @IBOutlet private weak var button: UIButton?
    @IBOutlet private weak var titleLabel: UILabel?
    
    private var action: VoidClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button?.layer.cornerRadius = 4
    }
    
    func config(title: String? = nil, buttonTitle: String, action: VoidClosure?) {
        titleLabel?.text = title
        titleLabel?.isHidden = title == nil
        button?.setTitle(buttonTitle, for: .normal)
        self.action = action
    }
    
    @IBAction private func buttonAction() {
        action?()
    }
}
