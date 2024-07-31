//
//  BankTransferAddTableViewCell.swift
//  ELProfileUI
//
//  Created by Oleksii Zabrodin on 18.03.2024.
//

import UIKit
import ELBase

class BankTransferAddTableViewCell: UITableViewCell {

    @IBOutlet var addMethotButton: UIButton!
    
    public var onAdd: VoidClosure?

    @IBAction func onMethodButtonTap(_ sender: Any) {
        onAdd?()
    }
}
