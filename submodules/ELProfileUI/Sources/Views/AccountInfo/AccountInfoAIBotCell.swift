//
//  AccountInfoAIBotCell.swift
//  ELProfileUI
//
//

import UIKit
import ELBase

class AccountInfoAIBotCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var valueLabel: UILabel?
    
    func config(title: String, value: String) {
        titleLabel?.text = title
        valueLabel?.text = value
    }
    
}
